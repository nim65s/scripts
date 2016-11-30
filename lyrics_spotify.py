#!/usr/bin/env python

import sys

from PyQt5.QtCore import QTimer
from PyQt5.QtWidgets import QAction, QApplication, QMainWindow, QTextEdit, QVBoxLayout, QWidget, qApp

from web_spotify import SpotifyLocalHTTPClient


class App(QMainWindow):
    def __init__(self):
        super(App, self).__init__()

        self.spotify = SpotifyLocalHTTPClient()

        start = QAction('Get Lyrics', self)
        start.triggered.connect(self.lyrics)

        pause = QAction('Pause', self)
        pause.triggered.connect(self.spotify.pause)

        exit = QAction('Exit', self)
        exit.setShortcut('Ctrl+Q')
        exit.triggered.connect(qApp.quit)

        toolbar = self.addToolBar('Toolbar')
        toolbar.addAction(start)
        toolbar.addAction(pause)
        toolbar.addAction(exit)

        vbox = QVBoxLayout()
        self.setLayout(vbox)

        central = QWidget()
        central.setLayout(vbox)
        self.setCentralWidget(central)

        self.view = QTextEdit()
        self.view.setReadOnly(True)
        self.lyrics()
        vbox.addWidget(self.view)

        self.timer = QTimer()
        self.timer.timeout.connect(self.lyrics)
        self.timer.start(1000)

        self.setWindowTitle("Spotify's Lyrics from Wika")
        self.show()

    def lyrics(self):
        self.view.setHtml(self.spotify.lyrics())


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())
