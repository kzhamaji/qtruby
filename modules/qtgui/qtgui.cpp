/*
 *   Copyright 2009-2011 by Richard Dale <richard.j.dale@gmail.com>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <QtCore/qdebug.h>
#include <QtGui/QApplication>

#include <global.h>
#include <marshall.h>

#include <smoke/qtgui_smoke.h>

#include "typeresolver.h"
#include "rubyqimage.h"
#include "rubyqitemselection.h"
#include "rubyqpainter.h"

namespace QtRuby {
extern Marshall::TypeHandler QtGuiHandlers[];
extern void registerQtGuiTypes();

static void initializeClasses(Smoke * smoke)
{
    Global::QGraphicsItemClassId = qtgui_Smoke->idClass("QGraphicsItem");
    Global::defineTypeResolver(Global::QGraphicsItemClassId, qgraphicsitemTypeResolver);

    for (int i = 1; i <= smoke->numClasses; i++) {
        Smoke::ModuleIndex classId(smoke, i);
        QString className = QString::fromLatin1(smoke->classes[i].className);

        if (    smoke->classes[i].external
                || className.contains("Internal")
                || className == "Qt" )
        {
            continue;
        }

        if (className.startsWith("Q"))
            className = className.mid(1).prepend("Qt::");

        VALUE klass = Global::initializeClass(classId, className);

        if (className == "Qt::Image") {
            rb_define_method(klass, "bits", (VALUE (*) (...)) qimage_bits, 0);
            rb_define_method(klass, "scanLine", (VALUE (*) (...)) qimage_scan_line, 1);
        } else if (className == "Qt::ItemSelection") {
            rb_define_method(klass, "[]", (VALUE (*) (...)) qitemselection_at, 1);
            rb_define_method(klass, "at", (VALUE (*) (...)) qitemselection_at, 1);
            rb_define_method(klass, "count", (VALUE (*) (...)) qitemselection_count, 0);
            rb_define_method(klass, "length", (VALUE (*) (...)) qitemselection_count, 0);
        } else if (className == "Qt::Painter") {
            rb_define_method(klass, "drawLines", (VALUE (*) (...)) qpainter_drawlines, -1);
            rb_define_method(klass, "draw_lines", (VALUE (*) (...)) qpainter_drawlines, -1);
            rb_define_method(klass, "drawRects", (VALUE (*) (...)) qpainter_drawrects, -1);
            rb_define_method(klass, "draw_rects", (VALUE (*) (...)) qpainter_drawrects, -1);
        }
    }
}

}

extern "C" {

Q_DECL_EXPORT void
Init_qtgui()
{
    init_qtgui_Smoke();
    QtRuby::Module qtgui_module = { "qtgui", new QtRuby::Binding(qtgui_Smoke) };
    QtRuby::Global::modules[qtgui_Smoke] = qtgui_module;
    QtRuby::registerQtGuiTypes();
    QtRuby::Marshall::installHandlers(QtRuby::QtGuiHandlers);
    QtRuby::initializeClasses(qtgui_Smoke);
    rb_require("qtgui/qtgui.rb");

    return;
}

}