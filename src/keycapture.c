//  Copyright (C) 2011-2015 Eidete Developers
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <stdio.h>
#include <glib.h>
#include <X11/Xproto.h>
#include <X11/Xlib.h>
#include <X11/XKBlib.h>
#include <X11/extensions/record.h> // libxtst-dev, Xtst

static Display* dpy;
static XRecordContext rc;

void key_pressed_cb(XPointer arg, XRecordInterceptData *d) {
    if (d->category != XRecordFromServer)
        return;

    xEvent* event = (xEvent*) d->data;

    unsigned char type = ((unsigned char*) d->data)[0] & 0x7F;
    unsigned char detail = ((unsigned char*) d->data)[1];
    unsigned int shiftlevel = 0;

    if (event->u.keyButtonPointer.state == 0 || event->u.keyButtonPointer.state == 1)
        shiftlevel = event->u.keyButtonPointer.state;

    switch (type) {
        case KeyPress:
            g_signal_emit_by_name (arg, "captured", XKeysymToString (XkbKeycodeToKeysym (dpy, detail, 0, shiftlevel)), FALSE);
            break;
        case KeyRelease:
            g_signal_emit_by_name (arg, "captured", XKeysymToString (XkbKeycodeToKeysym (dpy, detail, 0, shiftlevel)), TRUE);
            break;
        default:
            break;
    }

    XRecordFreeData (d);
}

void* intercept_key_thread (void *data) {
    XRecordClientSpec rcs;
    XRecordRange* rr;
    dpy = XOpenDisplay (NULL);

    if (rc != NULL) {
        if (!(rc = XRecordDisableContext (dpy, rc))) {
            fprintf (stderr, "XRecordDisableContext error\n");
        }
    }

    if (!(rr = XRecordAllocRange ())) {
        fprintf (stderr, "XRecordAllocRange error\n");
    }

    rr->device_events.first = KeyPress;
    rr->device_events.last = MotionNotify;
    rcs = XRecordAllClients;

    if (!(rc = XRecordCreateContext (dpy, 0, &rcs, 1, &rr, 1))) {
        fprintf (stderr, "XRecordCreateContext error\n");
    }

    XFree (rr);

    // No idea why this is needed - key recording doesn't seem to work without it!
    XkbKeycodeToKeysym (dpy, 11, 1, 0);

    if (!XRecordEnableContext (dpy, rc, key_pressed_cb, data)) {
        fprintf (stderr, "XRecordEnableContext error\n");
    }

    return 0;
}
