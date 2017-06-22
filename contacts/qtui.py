#!/usr/bin/env python3

import sys
from datetime import datetime
from pathlib import Path

from PyQt5.QtCore import QSize
from PyQt5.QtWidgets import (QAction, QApplication, QDialog, QFileDialog, QGridLayout, QLabel,
                             QLineEdit, QMainWindow, QPushButton, QTableWidget, QTableWidgetItem, qApp)

from vcards import Vcard
from vcf_parser import export_ab, import_ab

MAIN = {'EMAIL': 'EMAIL;TYPE=HOME,INTERNET', 'TEL': 'TEL;TYPE=CELL', 'X-JABBER': 'X-JABBER'}


def now():
    return datetime.now().strftime('%Y%m%dT%H%M%SZ')


class Contacts(QMainWindow):
    def __init__(self):
        super().__init__()

        self.vcards = {}

        self.statusBar()

        import_action = QAction('Import Addresse Books', self)
        import_action.triggered.connect(self.import_abs)
        export_action = QAction('Export Addresse Books', self)
        export_action.triggered.connect(self.export_ab)
        merge_action = QAction('Merge', self)
        merge_action.triggered.connect(self.merge)
        automerge_action = QAction('Auto-Merge', self)
        automerge_action.triggered.connect(self.automerge)
        deldup_action = QAction('Delete Duplicates', self)
        deldup_action.triggered.connect(self.delete_duplicates)
        fixtel_action = QAction('Fix Tel', self)
        fixtel_action.triggered.connect(self.fix_tel)
        fixcat_action = QAction('Fix Category', self)
        fixcat_action.triggered.connect(self.fix_category)
        exit_action = QAction('Exit', self)
        exit_action.triggered.connect(qApp.quit)

        toolbar = self.addToolBar('Toolbar')
        toolbar.addAction(import_action)
        toolbar.addAction(export_action)
        toolbar.addAction(merge_action)
        toolbar.addAction(automerge_action)
        toolbar.addAction(deldup_action)
        toolbar.addAction(fixtel_action)
        toolbar.addAction(fixcat_action)
        toolbar.addAction(exit_action)

        for path in Path('.').glob('*.vcf'):
            self.import_ab(path)

        self.setWindowTitle('float')
        self.show()

    def import_abs(self):
        for filename in QFileDialog.getOpenFileNames(self, 'Charge des carnets d’adresse', '.', '*.vcf')[0]:
            path = Path(filename).name  # TODO .name added for easier relative use
            self.import_ab(path)

    def import_ab(self, path):
        self.vcards.update(import_ab(str(path)))
        self.update_contacts()

    def update_contacts(self):
        self.update_keys()
        self.table = QTableWidget(len(self.vcards), len(self.keys) + 1, self)

        for i, key in enumerate(self.keys):
            self.table.setHorizontalHeaderItem(i, QTableWidgetItem(key))
        self.table.setHorizontalHeaderItem(len(self.keys), QTableWidgetItem('Carnet'))

        for i, vcard in enumerate(self.vcards.values()):
            for key, value in vcard.dict.items():
                self.table.setItem(i, self.keys_idx[key], QTableWidgetItem('|'.join(value)))
                self.table.setItem(i, len(self.keys), QTableWidgetItem(vcard.address_book))
        self.table.sortItems(self.keys_idx['FN'])
        self.setCentralWidget(self.table)

    def update_keys(self):
        self.keys = set()
        for vcard in self.vcards.values():
            self.keys |= set(vcard.dict.keys())
        self.keys = sorted(self.keys)
        self.keys_idx = {key: idx for idx, key in enumerate(self.keys)}

    def get_vcard_from_row(self, row):
        if row >= self.table.rowCount():
            return
        infos = set()
        for i in range(len(self.keys)):
            if self.table.item(row, i):
                for info in self.table.item(row, i).text().split('|'):
                    if info:
                        infos.add((self.table.horizontalHeaderItem(i).text(), info))
        return Vcard(self.table.item(row, len(self.keys)).text(), list(infos))

    def export_ab(self):
        address_books = {}
        for row in range(self.table.rowCount()):
            v = self.get_vcard_from_row(row)
            if v.address_book in address_books:
                address_books[v.address_book][v.uid] = v
            else:
                address_books[v.address_book] = {v.uid: v}
        for address_book, addresses in address_books.items():
            export_ab(addresses, f'{address_book}.vcf')

    def merge(self):
        vcards = {}
        for sr in self.table.selectedRanges():
            for row in range(sr.topRow(), 1 + sr.bottomRow()):
                vcards[row] = self.get_vcard_from_row(row)
        MergeDialog(vcards, self.keys, parent=self).show()

    def automerge(self):
        self.delete_duplicates()
        old = 'nothing'
        for row in range(self.table.rowCount()):
            new = self.table.item(row, self.keys_idx['FN']).text()
            if old == new:
                MergeDialog({row: self.get_vcard_from_row(row), row - 1: self.get_vcard_from_row(row - 1)}, self.keys,
                            parent=self).show()
                break
            old = new

    def fix_tel(self):
        for row in range(self.table.rowCount()):
            item = self.table.item(row, self.keys_idx[MAIN['TEL']])
            if not item:
                continue
            tels = [tel.replace(' ', '') for tel in item.text().split('|')]
            tels = [tel.replace('00', '+', 1) if tel.startswith('00') else tel for tel in tels]
            for i in range(1, 10):
                tels = [tel.replace(f'0{i}', f'+33{i}', 1) if tel.startswith(f'0{i}') else tel for tel in tels]
            tels = [' '.join([t[:3], t[3], t[4:6], t[6:8], t[8:10], t[10:]])
                    if t.startswith('+33') else t for t in tels]
            self.table.item(row, self.keys_idx['TEL;TYPE=CELL']).setText('|'.join(tels))

    def delete_duplicates(self):
        old = Vcard('pipo', {})
        for row in range(self.table.rowCount()):
            v = self.get_vcard_from_row(row)
            if v is None:
                break
            if v == old:
                print(f'delete row {row} for vcard {v}')
                self.table.removeRow(row)
            else:
                old = v

    def fix_category(self):
        for row in range(self.table.rowCount()):
            for key in self.keys:
                for kind in MAIN.keys():
                    if kind in key and key != MAIN[kind]:
                        item = self.table.item(row, self.keys_idx[key])
                        if item and item.text():
                            it = self.table.item(row, self.keys_idx[MAIN[kind]])
                            if not it or not it.text():
                                self.table.setItem(row, self.keys_idx[MAIN[kind]], QTableWidgetItem(item.text()))
                            else:
                                it.setText('|'.join(it.text().split('|') + item.text().split('|')))
                            item.setText('')


class MergeDialog(QDialog):
    def __init__(self, vcards, keys, parent):
        self.vcards, self.keys = vcards, keys
        super().__init__(parent)

        done = QPushButton("Done", self)
        done.clicked.connect(self.merge_done)

        self.edits = {}
        layout = QGridLayout()
        for i, key in enumerate(self.keys):
            if key not in ['REV', 'UID', 'VERSION', 'PRODID']:
                edit = QLineEdit(self)

                items = set()
                for v in self.vcards.values():
                    if key in v.dict and v.dict[key]:
                        for item in v.dict[key]:
                            items.add(item)
                edit.setText('|'.join(items))
                layout.addWidget(QLabel(key), i, 0)
                layout.addWidget(edit, i, 1)
                self.edits[key] = edit

        self.setLayout(layout)

    def merge_done(self, *args):
        edits = {key: value.text() for key, value in self.edits.items()}
        edits.update(REV=now(), PRODID='Nim', VERSION='3.0')
        for row, vcard in self.vcards.items():
            edits.update(UID=vcard.uid)
            for key in self.keys:
                self.parent().table.setItem(row, self.parent().keys_idx[key], QTableWidgetItem(edits[key]))
        self.accept()

    def sizeHint(self):
        return QSize(1900, 400)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = Contacts()
    sys.exit(app.exec_())
