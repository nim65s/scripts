#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
import sys

from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import (QAction, QApplication, QGridLayout, QInputDialog,
                             QMainWindow, QMessageBox, QPushButton, QWidget, qApp)


class Board(QWidget):
    def __init__(self, height, width, mines, size):
        super(Board, self).__init__()
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

    def click(self):
        self.demine(self.sender(), force=self.sender().isFlat())
        self.check_victory()

    def right_click(self):
        btn = self.sender()
        if btn.isFlat():
            self.demine(btn, force=True)
        else:
            btn.setText('!' if btn.text() == ' ' else ' ')
        self.check_victory()

    def around(self, x, y):
        for i in [-1, 0, 1]:
            if 0 <= x + i < self.width:
                for j in [-1, 0, 1]:
                    if 0 <= y + j < self.height:
                        yield x + i, y + j

    def demine(self, btn, force=False):
        if not force and btn.isFlat() or btn.text() == '!':
            return True
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
        QMessageBox.question(self, 'Fin', "Gagné !", QMessageBox.Ok)
        self.init()

    def end(self):
        for x in range(self.width):
            for y in range(self.height):
                if self.buttons[(x, y)].bomb:
                    self.buttons[(x, y)].setText('/o\\')
        QMessageBox.question(self, 'Fin', "Perdu !", QMessageBox.Ok)
        self.init()


class DedeNimeur(QMainWindow):
    def __init__(self):
        super(DedeNimeur, self).__init__()
        self.statusBar()

        self.size, self.height, self.width, self.mines = 30, 10, 10, 10
        self.board = Board(self.height, self.width, self.mines, self.size)
        self.setCentralWidget(self.board)

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
        text, ok = QInputDialog.getText(self, 'Settings', 'width')
        if ok:
            self.height = int(text)
            self.init()

    def set_width(self):
        text, ok = QInputDialog.getText(self, 'Settings', 'height')
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


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = DedeNimeur()
    sys.exit(app.exec_())
