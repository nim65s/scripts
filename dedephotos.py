#!/usr/bin/env python
"""
show similar images in dirs sys.argv
allow to move some of them into "removed" dir
"""

import os
import sys
from functools import partial
from pathlib import Path

import imagehash
from PIL import Image
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QPixmap
from PyQt5.QtWidgets import (QAction, QApplication, QCheckBox, QGridLayout,
                             QLabel, QMainWindow, QVBoxLayout, QWidget, qApp)
from tqdm import tqdm


class ImgChooser(QWidget):
    """
    Main widget
    """

    def __init__(self, img_no, images, ddp, *args, **kwargs):
        super(ImgChooser, self).__init__(*args, **kwargs)

        self.img_no = img_no
        self.images = images
        self.removed = []
        self.widgets = []
        self.ddp = ddp
        self.grid = QGridLayout(self)
        for col in range(ddp.imgs):
            checkbox, label = QCheckBox(self), QLabel(self)
            self.widgets.append((checkbox, label))
            self.grid.addWidget(checkbox, 0, col)
            self.grid.addWidget(label, 1, col)

        self.draw()

    def set_images(self, img_no, images, removed):
        """
        update the grid layout for images
        """
        self.img_no = img_no
        self.images = images
        self.removed = removed
        self.draw()

    def draw(self):
        """
        update grid
        """
        for col in range(self.ddp.imgs):
            checkbox, label = self.widgets[col]
            if col < len(self.images):
                img = self.images[col]
                checkbox.setText(str(img))
                try:
                    checkbox.stateChanged.disconnect()
                except TypeError:
                    pass
                checkbox.setCheckState(Qt.Checked if img in self.removed else Qt.Unchecked)
                checkbox.stateChanged.connect(partial(self.ddp.updt_rm, img_no=self.img_no, img=img))
                pix = QPixmap(str(self.images[col]))
                pix.setDevicePixelRatio(2)
                label.setPixmap(pix)
                checkbox.show()
                label.show()
            else:
                checkbox.hide()
                label.hide()


class DedePhotos(QMainWindow):
    """
    QMainWindow
    """

    def __init__(self, database, *args, **kwargs):
        super(DedePhotos, self).__init__(*args, **kwargs)
        self.statusBar()
        self.database = database
        self.db_keys = sorted(database.keys())
        self.current = 0

        self.imgs = max(len(v) for v in database.values())

        self.photos = ImgChooser(self.current, self.database[self.db_keys[self.current]], self)
        self.removed = {key: [] for key in self.db_keys}

        vbox = QVBoxLayout()
        vbox.addWidget(self.photos)

        central = QWidget()
        central.setLayout(vbox)
        self.setCentralWidget(central)

        _exit = QAction('Exit', self)
        _exit.setStatusTip('Exit')
        _exit.setShortcut('Ctrl+Q')
        _exit.triggered.connect(qApp.quit)

        _next = QAction('Next', self)
        _next.setStatusTip('Next')
        _next.triggered.connect(self.next)

        _prev = QAction('Prev', self)
        _prev.setStatusTip('Prev')
        _prev.triggered.connect(self.prev)

        _done = QAction('Done', self)
        _done.setStatusTip('Done')
        _done.triggered.connect(self.done)

        self.count = QAction(f'{self.current} / {len(self.db_keys)}', self)

        toolbar = self.addToolBar('Toolbar')
        toolbar.addAction(_next)
        toolbar.addAction(_prev)
        toolbar.addAction(_done)
        toolbar.addAction(_exit)
        toolbar.addAction(self.count)

        self.setWindowTitle(u'DédéPhotos')
        self.show()

    def update_photos(self):
        """
        update img_no & images in ImgChooser
        """
        self.count.setText(f'{self.current} / {len(self.db_keys)}')
        key = self.db_keys[self.current]
        self.photos.set_images(self.current, self.database[key], self.removed[key])

    def next(self):
        """
        go to next img set
        """
        if self.current < len(self.db_keys) - 1:
            self.current += 1
            self.update_photos()

    def prev(self):
        """
        go to prev img set
        """
        if self.current > 0:
            self.current -= 1
            self.update_photos()

    def updt_rm(self, state, img_no=None, img=None):
        """
        get an update from ImgChooser checkboxes
        """
        if img in self.removed[self.db_keys[img_no]]:
            if state != Qt.Unchecked:
                print('not unchecked', img_no, img, state)
            self.removed[self.db_keys[img_no]].remove(img)
        else:
            if state != Qt.Checked:
                print('not checked', img_no, img, state)
            self.removed[self.db_keys[img_no]].append(img)

    def done(self):
        """
        move self.removed stuff into "./removed" dir
        """
        for imgs in self.removed.values():
            for img in imgs:
                os.renames(img, Path('./removed') / img)


def read_database(dirs):
    """
    get all images and regroup them by hash
    return only doublons
    """
    database = {}
    fails = []
    for argv in dirs:
        for img in tqdm(list(Path(argv).glob(f'**/*.jpg')), desc=argv):
            try:
                image = Image.open(img)
                img_hash = str(imagehash.phash(image))
                database[img_hash] = database.get(img_hash, []) + [img]
            except OSError:
                fails.append(str(img))
    print('FAIL on:', '\n'.join(fails))
    return {key: values for key, values in database.items() if len(values) > 1}


if __name__ == '__main__':
    app = QApplication([])
    ex = DedePhotos(read_database(sys.argv[1:]))
    sys.exit(app.exec_())
