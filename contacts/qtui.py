#!/usr/bin/env python3

import sys
from pathlib import Path

from PyQt5.QtWidgets import QAction, QApplication, QFileDialog, QMainWindow, QTableWidget, QTableWidgetItem, qApp

from vcards import Vcard
from vcf_parser import export_ab, import_ab


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
        exit_action = QAction('Exit', self)
        exit_action.triggered.connect(qApp.quit)

        toolbar = self.addToolBar('Toolbar')
        toolbar.addAction(import_action)
        toolbar.addAction(export_action)
        toolbar.addAction(merge_action)
        toolbar.addAction(exit_action)

        self.import_ab('Fusion.vcf')

        self.setWindowTitle('float')
        self.show()

    def import_abs(self):
        for filename in QFileDialog.getOpenFileNames(self, 'Charge des carnets d’adresse')[0]:
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
        infos = []
        for i in range(len(self.keys)):
            if self.table.item(row, i):
                for info in self.table.item(row, i).text().split('|'):
                    if info:
                        infos.append((self.table.horizontalHeaderItem(i).text(), info))
        return Vcard(self.table.item(row, len(self.keys)).text(), infos)

    def export_ab(self):
        address_books = {}
        for row in range(self.table.rowCount()):
            v = self.get_vcard_from_row(row)
            if v.address_book in address_books:
                address_books[v.address_book][v.uid] = v
            else:
                address_books[v.address_book] = {v.uid: v}
        for address_book, addresses in address_books.items():
            export_ab(addresses, f'saved_{address_book}.vcf')

    def merge(self):
        vcards = {}
        for sr in self.table.selectedRanges():
            for row in range(sr.topRow(), 1 + sr.bottomRow()):
                v = self.get_vcard_from_row(row)
                vcards[v.uid] = v
        print(vcards)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = Contacts()
    sys.exit(app.exec_())
