/*
 * Author: Christopher Jackson (christopher.jackson@gmail.com)
 * GUI simulator for RubikAI.
 *
 */

#include <QtCore>
#include <QtGui>
#include "RubikAI.h"

int main(int argc, char* argv[])
{
  QApplication app(argc, argv);
  RubikAI rubikAI;
  rubikAI.show();
  return app.exec();
}
