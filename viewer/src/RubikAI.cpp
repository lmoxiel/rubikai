#include "RubikAI.h"

RubikAI::RubikAI(QWidget *parent) : QWidget(parent) {
  mainLayout = new QVBoxLayout(this);
  topSpacer = new QSpacerItem(10,20);
  topLayout = new QHBoxLayout();   
  bottomLayout = new QHBoxLayout();

  threedBackground = new QWidget();

  frontBackground = new QWidget();
  backBackground = new QWidget(); 
  leftBackground = new QWidget();
  rightBackground = new QWidget(); 
  topBackground = new QWidget(); 
  bottomBackground = new QWidget(); 

  frontFaceLayout = new QGridLayout();
  backFaceLayout = new QGridLayout();
  leftFaceLayout = new QGridLayout();
  rightFaceLayout = new QGridLayout();
  topFaceLayout = new QGridLayout();
  bottomFaceLayout = new QGridLayout();

  // Setup menu items
  loadAct = new QAction("&Load...", this);
  loadAct->setShortcut(QKeySequence("Ctrl+L"));
  loadAct->setStatusTip("Load a RubikAI simulator file.");
  loadAct->setEnabled(false);
  connect(loadAct, SIGNAL(triggered()), this, SLOT(loadFile()));

  loadAndRunAct = new QAction("Load and &Run...", this);
  loadAndRunAct->setShortcut(QKeySequence("Ctrl+R"));
  loadAndRunAct->setStatusTip("Load and run a RubikAI simulator file.");
  connect(loadAndRunAct, SIGNAL(triggered()), this, SLOT(loadAndRunFile()));

  pauseAct = new QAction("&Pause", this);
  pauseAct->setShortcut(QKeySequence("Ctrl+P"));
  pauseAct->setStatusTip("Pauses the simulation.");
  pauseAct->setEnabled(false);
  connect(pauseAct, SIGNAL(triggered()), this, SLOT(pause()));

  settingsAct = new QAction("&Settings...", this);
  settingsAct->setShortcut(QKeySequence("Ctrl+S"));
  settingsAct->setStatusTip("Set options such as simulation speed.");
  settingsAct->setEnabled(false);
  connect(settingsAct, SIGNAL(triggered()), this, SLOT(showSettings())); // change to dialog widget
  
  exitAct = new QAction("E&xit", this);
  exitAct->setShortcut(QKeySequence("Ctrl+Q"));
  exitAct->setStatusTip("Exits this program.");
  connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

  aboutAct = new QAction("&About", this);
  aboutAct->setShortcut(QKeySequence("F1"));
  aboutAct->setStatusTip("Copyright(c) 2009-2010  Christopher Jackson <moxie@uga.edu>");
  //aboutAct->setMenuRole(QAction::AboutRole);
  connect(aboutAct, SIGNAL(triggered()), this, SLOT(about()));

  menuBar = new QMenuBar(this);
  fileMenu = menuBar->addMenu("&File");
  fileMenu->addAction(loadAct);
  fileMenu->addAction(loadAndRunAct);
  fileMenu->addAction(pauseAct);
  fileMenu->addSeparator();
  fileMenu->addAction(settingsAct);
  fileMenu->addSeparator();
  fileMenu->addAction(exitAct);

  helpMenu = menuBar->addMenu("&Help");
  helpMenu->addAction(aboutAct);
  

  //QLabel *moveLabel = new QLabel("Current Move");
  frontLabel = new QLabel("Front");
  backLabel = new QLabel("Back");
  leftLabel = new QLabel("Left");
  rightLabel = new QLabel("Right");
  topLabel = new QLabel("Top");
  bottomLabel = new QLabel("Bottom");
 
  // Customize Label Stylesheets
  frontLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");
  leftLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");
  backLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");
  rightLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");
  topLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");
  bottomLabel->setStyleSheet("color: white;"
			    "font-size: 16px;"
			    "font-style: bold");

  //Initialize the 6 faces
  for (int i=0; i < (CUBE_LENGTH * CUBE_LENGTH); i++) {
    //blue orange green red yellow white
    frontFace[i] = new QWidget();
    frontFace[i]->setStyleSheet("background-color: blue;");
    leftFace[i] = new QWidget();
    leftFace[i]->setStyleSheet("background-color: orange;");
    backFace[i] = new QWidget();
    backFace[i]->setStyleSheet("background-color: green;");
    rightFace[i] = new QWidget();
    rightFace[i]->setStyleSheet("background-color: red;");
    topFace[i] = new QWidget();
    topFace[i]->setStyleSheet("background-color: yellow;");
    bottomFace[i] = new QWidget();
    bottomFace[i]->setStyleSheet("background-color: white;");
  }

  // Initialize face layouts
  frontFaceLayout->setRowMinimumHeight(0,40);
  frontFaceLayout->setRowMinimumHeight(1,40);
  frontFaceLayout->setRowMinimumHeight(2,40);
  frontFaceLayout->setRowMinimumHeight(3,40);
  frontFaceLayout->setColumnMinimumWidth(0,40);
  frontFaceLayout->setColumnMinimumWidth(1,40);
  frontFaceLayout->setColumnMinimumWidth(2,40);

  leftFaceLayout->setRowMinimumHeight(0,40);
  leftFaceLayout->setRowMinimumHeight(1,40);
  leftFaceLayout->setRowMinimumHeight(2,40);
  leftFaceLayout->setRowMinimumHeight(3,40);
  leftFaceLayout->setColumnMinimumWidth(0,40);
  leftFaceLayout->setColumnMinimumWidth(1,40);
  leftFaceLayout->setColumnMinimumWidth(2,40);

  backFaceLayout->setRowMinimumHeight(0,40);
  backFaceLayout->setRowMinimumHeight(1,40);
  backFaceLayout->setRowMinimumHeight(2,40);
  backFaceLayout->setRowMinimumHeight(3,40);
  backFaceLayout->setColumnMinimumWidth(0,40);
  backFaceLayout->setColumnMinimumWidth(1,40);
  backFaceLayout->setColumnMinimumWidth(2,40);

  rightFaceLayout->setRowMinimumHeight(0,40);
  rightFaceLayout->setRowMinimumHeight(1,40);
  rightFaceLayout->setRowMinimumHeight(2,40);
  rightFaceLayout->setRowMinimumHeight(3,40);
  rightFaceLayout->setColumnMinimumWidth(0,40);
  rightFaceLayout->setColumnMinimumWidth(1,40);
  rightFaceLayout->setColumnMinimumWidth(2,40);

  topFaceLayout->setRowMinimumHeight(0,40);
  topFaceLayout->setRowMinimumHeight(1,40);
  topFaceLayout->setRowMinimumHeight(2,40);
  topFaceLayout->setRowMinimumHeight(3,40);
  topFaceLayout->setColumnMinimumWidth(0,40);
  topFaceLayout->setColumnMinimumWidth(1,40);
  topFaceLayout->setColumnMinimumWidth(2,40);

  bottomFaceLayout->setRowMinimumHeight(0,40);
  bottomFaceLayout->setRowMinimumHeight(1,40);
  bottomFaceLayout->setRowMinimumHeight(2,40);
  bottomFaceLayout->setRowMinimumHeight(3,40);
  bottomFaceLayout->setColumnMinimumWidth(0,40);
  bottomFaceLayout->setColumnMinimumWidth(1,40);
  bottomFaceLayout->setColumnMinimumWidth(2,40);

  // initialize the faces onto the layout
  for (int i=0; i < CUBE_LENGTH; i++) {
    for(int j=0; j < CUBE_LENGTH; j++) {
      frontFaceLayout->addWidget(frontLabel,0,0,1,3, Qt::AlignCenter);
      frontFaceLayout->addWidget(frontFace[i*CUBE_LENGTH+j],(i+1),j,1,1);

      leftFaceLayout->addWidget(leftLabel,0,0,1,3, Qt::AlignCenter);
      leftFaceLayout->addWidget(leftFace[i*CUBE_LENGTH+j],(i+1),j,1,1);

      backFaceLayout->addWidget(backLabel,0,0,1,3, Qt::AlignCenter);
      backFaceLayout->addWidget(backFace[i*CUBE_LENGTH+j],(i+1),j,1,1);

      rightFaceLayout->addWidget(rightLabel,0,0,1,3, Qt::AlignCenter);
      rightFaceLayout->addWidget(rightFace[i*CUBE_LENGTH+j],(i+1),j,1,1);

      topFaceLayout->addWidget(topLabel,0,0,1,3, Qt::AlignCenter);
      topFaceLayout->addWidget(topFace[i*CUBE_LENGTH+j],(i+1),j,1,1);

      bottomFaceLayout->addWidget(bottomLabel,0,0,1,3, Qt::AlignCenter);
      bottomFaceLayout->addWidget(bottomFace[i*CUBE_LENGTH+j],(i+1),j,1,1);
    }
  }

  // Initialize background face widgets
  frontBackground->setLayout(frontFaceLayout);
  frontBackground->setStyleSheet("background: black");
  topLayout->addWidget(frontBackground);
  
  backBackground->setLayout(backFaceLayout);
  backBackground->setStyleSheet("background: black");
  topLayout->addWidget(backBackground);
  
  leftBackground->setLayout(leftFaceLayout);
  leftBackground->setStyleSheet("background: black");
  topLayout->addWidget(leftBackground);
  
  rightBackground->setLayout(rightFaceLayout);
  rightBackground->setStyleSheet("background: black");
  topLayout->addWidget(rightBackground);
  
  topBackground->setLayout(topFaceLayout);
  topBackground->setStyleSheet("background: black");
  topLayout->addWidget(topBackground);
  
  bottomBackground->setLayout(bottomFaceLayout);
  bottomBackground->setStyleSheet("background: black");
  topLayout->addWidget(bottomBackground);
  
  //Initialize topLayout and bottomLayout
  topLayout->setGeometry(QRect(0,0,150, 120));
  bottomLayout->addWidget(threedBackground);
  mainLayout->addItem(topSpacer);
  mainLayout->addLayout(topLayout);
  mainLayout->addLayout(bottomLayout);
  
  // start pause off as false
  m_pause = true;

  // Set main layout for this window and resize
  setLayout(mainLayout);
  setWindowTitle("RubikAI");
  resize(150,180);
}

void RubikAI::updateFace(QWidget* face[], QStringList colors) {
  //for (int i=0; i< colors.size(); i++) {
  for (int i=0; i < (CUBE_LENGTH * CUBE_LENGTH); i++) {
    face[i]->setStyleSheet("background-color: " + colors.at(i+1) + ";");
  }
}

void RubikAI::loadAndRunFile() {
  m_pause = false;
  fileName = QFileDialog::getOpenFileName(this, "Open .rbk file",".","Rubik Files (*.rbk)");
  runFile();
}

void RubikAI::loadFile() {
  m_pause = true;
  fileName = QFileDialog::getOpenFileName(this, "Open .rbk file",".","Rubik Files (*.rbk)");
  runFile();
}

void RubikAI::runFile() {
  QString state[7];
  QFile file(fileName);
  file.open(QIODevice::ReadOnly);
  QTextStream input(&file);
  // while file not empty and pause not true, process the file one movement at a time
  while (!input.atEnd() &&!(m_pause == true)) {
    state[0] = input.readLine();
    state[1] = input.readLine();
    state[2] = input.readLine();
    state[3] = input.readLine();
    state[4] = input.readLine();
    state[5] = input.readLine();
    state[6] = input.readLine();
    input.readLine(); // read in the blank line separating states

    if (state[0] == "") break; // in case we read in just newline characters

    // update each face and call update after all faces have been set
    updateFace(frontFace, state[1].split(" "));
    updateFace(leftFace, state[2].split(" "));  
    updateFace(backFace, state[3].split(" "));
    updateFace(rightFace, state[4].split(" "));
    updateFace(topFace, state[5].split(" "));
    updateFace(bottomFace, state[6].split(" "));
    
    repaint();  // schedules the repaint
    SpeedThread::msleep(1000 * 1.0);
  }
  file.close();
}

void RubikAI::pause() {
  m_pause = !m_pause;
  if (m_pause == true)
    pauseAct->setText("&Pause");
  else
    pauseAct->setText("&Unpause");
}

void RubikAI::showSettings() {
  // Show the Setings... window (modal)
}

void RubikAI::about() {
  QMessageBox::about(this, "About Menu", 
		     "Rubik's Cube simulation demonstrating applications of local search algorithms");
}
