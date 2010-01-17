#ifndef RUBIKAI_H
#define RUBIKAI_H

#include <QtCore>
#include <QtGui>

static const int CUBE_LENGTH = 3;

class RubikAI: public QWidget
{
  class SpeedThread: public QThread
  {
  public:
    static void msleep(unsigned long msecs) { QThread::msleep(msecs); }
  };

  Q_OBJECT

public:
  RubikAI(QWidget *parent = 0);
  void updateFace(QWidget* face[], QStringList colors);
  void runFile();
						      
public slots:
  void about();
  void loadFile();
  void loadAndRunFile();
  void pause();
  void showSettings();

private:
 
  // Pause the animation?
  bool m_pause;
  QString fileName;

  // Main widgets and layouts
  QVBoxLayout *mainLayout;
  QSpacerItem *topSpacer;
  QHBoxLayout *topLayout;
  QHBoxLayout *bottomLayout;
  
  // Menu widgets and Actions
  QMenuBar *menuBar;
  QMenu *fileMenu;
  QMenu *helpMenu;
  QAction *loadAct;
  QAction *loadAndRunAct;
  QAction *pauseAct;
  QAction *settingsAct;
  QAction *exitAct;
  QAction *aboutAct;
  

  // The 3D background
  QWidget *threedBackground;

  // The 6 faces background widgets; Background to draw cube
  QWidget *frontBackground;
  QWidget *backBackground;
  QWidget *leftBackground;
  QWidget *rightBackground;
  QWidget *topBackground;
  QWidget *bottomBackground;

  // The 6 faces layout
  QGridLayout *frontFaceLayout;
  QGridLayout *backFaceLayout;
  QGridLayout *leftFaceLayout;
  QGridLayout *rightFaceLayout;
  QGridLayout *topFaceLayout;
  QGridLayout *bottomFaceLayout;

  // The 6 faces labels + 1 move label
  //QLabel *moveLabel;
  QLabel *frontLabel;
  QLabel *backLabel;
  QLabel *leftLabel;
  QLabel *rightLabel;
  QLabel *topLabel;
  QLabel *bottomLabel;

  // The 6 faces ( front, back, left, right, top, bottom ) each with # widgets
  QWidget* frontFace[CUBE_LENGTH * CUBE_LENGTH];
  QWidget* leftFace[CUBE_LENGTH * CUBE_LENGTH];
  QWidget* backFace[CUBE_LENGTH * CUBE_LENGTH];
  QWidget* rightFace[CUBE_LENGTH * CUBE_LENGTH];
  QWidget* topFace[CUBE_LENGTH * CUBE_LENGTH];
  QWidget* bottomFace[CUBE_LENGTH * CUBE_LENGTH];

};

#endif
