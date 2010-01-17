/****************************************************************************
** Meta object code from reading C++ file 'RubikAI.h'
**
** Created: Thu Dec 24 14:20:22 2009
**      by: The Qt Meta Object Compiler version 59 (Qt 4.4.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "RubikAI.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'RubikAI.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 59
#error "This file was generated using the moc from 4.4.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_RubikAI[] = {

 // content:
       1,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   10, // methods
       0,    0, // properties
       0,    0, // enums/sets

 // slots: signature, parameters, type, tag, flags
       9,    8,    8,    8, 0x0a,
      17,    8,    8,    8, 0x0a,
      28,    8,    8,    8, 0x0a,
      45,    8,    8,    8, 0x0a,
      53,    8,    8,    8, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_RubikAI[] = {
    "RubikAI\0\0about()\0loadFile()\0"
    "loadAndRunFile()\0pause()\0showSettings()\0"
};

const QMetaObject RubikAI::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_RubikAI,
      qt_meta_data_RubikAI, 0 }
};

const QMetaObject *RubikAI::metaObject() const
{
    return &staticMetaObject;
}

void *RubikAI::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_RubikAI))
        return static_cast<void*>(const_cast< RubikAI*>(this));
    return QWidget::qt_metacast(_clname);
}

int RubikAI::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: about(); break;
        case 1: loadFile(); break;
        case 2: loadAndRunFile(); break;
        case 3: pause(); break;
        case 4: showSettings(); break;
        }
        _id -= 5;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
