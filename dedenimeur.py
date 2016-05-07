#!/usr/bin/env python
# -*- coding: utf-8 -*-

# TODO
# facile / dur

import random
import sys

from PyQt5.QtCore import QBasicTimer, QElapsedTimer, Qt
from PyQt5.QtWidgets import (QAction, QApplication, QGridLayout, QInputDialog, QLCDNumber,
                             QMainWindow, QMessageBox, QPushButton, QVBoxLayout, QWidget, qApp)

COLORS = ["rgba(0, 0, 0, 0)", "blue", "green", "red", "DarkBlue", "black", "DeepPink", "violet", "brown"]


class Board(QWidget):
    def __init__(self, height, width, mines, size, *args, **kwargs):
        super(Board, self).__init__(*args, **kwargs)
        self.size, self.height, self.width, self.mines = size, height, width, mines
        self.grid = QGridLayout()
        self.grid.setHorizontalSpacing(0)
        self.grid.setVerticalSpacing(0)
        self.setLayout(self.grid)
        self.buttons = {}
        self.init()

    def init(self):
        for btn in self.buttons.values():
            btn.setParent(None)
        self.buttons = {}
        for x in range(self.width):
            for y in range(self.height):
                btn = QPushButton(' ')
                btn.position = (x, y)
                btn.bomb = False
                btn.setFixedSize(self.size, self.size)
                btn.clicked.connect(self.click)
                btn.setContextMenuPolicy(Qt.CustomContextMenu)
                btn.customContextMenuRequested.connect(self.right_click)
                self.grid.addWidget(btn, y, x)
                self.buttons[(x, y)] = btn
        for mine in range(self.mines):
            while True:
                x, y = random.randrange(self.width), random.randrange(self.height)
                if not self.buttons[(x, y)].bomb:
                    self.buttons[(x, y)].bomb = True
                    break
        self.started = False

    def click(self):
        if not self.started:
            self.parent().parent().start_timers()
            self.started = True
        self.demine(self.sender(), force=self.sender().isFlat())
        self.check_victory()

    def right_click(self):
        btn = self.sender()
        if not btn.isFlat():
            btn.setText('!' if btn.text() == ' ' else ' ')

    def around(self, x, y):
        for i in [-1, 0, 1]:
            if 0 <= x + i < self.width:
                for j in [-1, 0, 1]:
                    if 0 <= y + j < self.height:
                        yield x + i, y + j

    def demine(self, btn, force=False):
        if not force and btn.isFlat() or btn.text() == '!':
            return True
        if force and btn.isFlat():
            n = 0
            for x, y in self.around(*btn.position):
                if self.buttons[(x, y)].isFlat():
                    continue
                if self.buttons[(x, y)].bomb:
                    n += 1
                if self.buttons[(x, y)].text() == '!':
                    n -= 1
            if n != 0:
                return False
        btn.setFlat(True)
        x, y = btn.position
        if btn.bomb:
            self.end()
            return False
        n = 0
        for u, v in self.around(x, y):
            if self.buttons[(u, v)].bomb:
                n += 1
        btn.setText(str(n))
        btn.setStyleSheet("color: %s;" % COLORS[n])
        if n == 0 or force:
            for u, v in self.around(x, y):
                if not self.demine(self.buttons[(u, v)]):
                    return False
        return True

    def check_victory(self):
        for btn in self.buttons.values():
            if not btn.bomb and not btn.isFlat():
                return
        for x in range(self.width):
            for y in range(self.height):
                if self.buttons[(x, y)].bomb:
                    self.buttons[(x, y)].setText('\\o/')
        QMessageBox.question(self, 'Fin', "Gagné en %ims!" % self.parent().parent().stop_timers(), QMessageBox.Ok)
        self.init()

    def end(self):
        for x in range(self.width):
            for y in range(self.height):
                if self.buttons[(x, y)].bomb:
                    self.buttons[(x, y)].setText('/o\\')
        self.parent().parent().stop_timers()
        QMessageBox.question(self, 'Fin', "Perdu !", QMessageBox.Ok)
        self.init()


class DedeNimeur(QMainWindow):
    def __init__(self):
        super(DedeNimeur, self).__init__()
        self.statusBar()

        self.size, self.height, self.width, self.mines = 30, 10, 10, 10
        self.lcd = QLCDNumber()
        self.lcd.setFixedSize(300, 60)
        self.board = Board(self.height, self.width, self.mines, self.size)
        self.timer = QBasicTimer()
        self.real_timer = QElapsedTimer()

        vbox = QVBoxLayout()
        vbox.addWidget(self.lcd)
        vbox.addWidget(self.board)

        central = QWidget()
        central.setLayout(vbox)
        self.setCentralWidget(central)

        start = QAction('Start', self)
        start.setStatusTip('Start')
        start.setShortcut('Ctrl+N')
        start.triggered.connect(self.init)

        exit = QAction('Exit', self)
        exit.setStatusTip('Exit')
        exit.setShortcut('Ctrl+Q')
        exit.triggered.connect(qApp.quit)

        height = QAction('Height', self)
        height.setStatusTip('Set board width')
        height.triggered.connect(self.set_height)
        width = QAction('Width', self)
        width.setStatusTip('Set board height')
        width.triggered.connect(self.set_width)
        mines = QAction('Mines', self)
        mines.setStatusTip('Set board mines')
        mines.triggered.connect(self.set_mines)
        size = QAction('Size', self)
        size.setStatusTip('Set button size')
        size.triggered.connect(self.set_size)

        toolbar = self.addToolBar('Toolbar')
        toolbar.addAction(start)
        toolbar.addAction(width)
        toolbar.addAction(height)
        toolbar.addAction(mines)
        toolbar.addAction(size)
        toolbar.addAction(exit)

        self.setWindowTitle(u'DédéNimeur')
        self.show()

    def init(self):
        if self.mines < self.height * self.width:
            self.board.height = self.height
            self.board.width = self.width
            self.board.mines = self.mines
            self.board.size = self.size
            self.board.init()
        else:
            QMessageBox.question(self, 'NOPE', u"Va falloir spécifier un truc cohérent…", QMessageBox.Ok)

    def set_height(self):
        text, ok = QInputDialog.getText(self, 'Settings', 'height')
        if ok:
            self.height = int(text)
            self.init()

    def set_width(self):
        text, ok = QInputDialog.getText(self, 'Settings', 'width')
        if ok:
            self.width = int(text)
            self.init()

    def set_mines(self):
        text, ok = QInputDialog.getText(self, 'Settings', 'mines')
        if ok:
            self.mines = int(text)
            self.init()

    def set_size(self):
        text, ok = QInputDialog.getText(self, 'Settings', 'size')
        if ok:
            self.size = int(text)
            self.init()

    def start_timers(self):
        self.timer.start(100, self)
        self.real_timer.start()
        self.lcd.display(int(self.real_timer.elapsed() / 1000))

    def stop_timers(self):
        self.timer.stop()
        return self.real_timer.elapsed()

    def timerEvent(self, e):
        self.lcd.display(int(self.real_timer.elapsed() / 1000))


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = DedeNimeur()
    sys.exit(app.exec_())
