#!/usr/bin/python2
#-*- coding: utf-8 -*-

from __future__ import with_statement

import filecmp
import os
import pprint
import re
import shutil
import sys
import time
import webbrowser
import zipfile
from os.path import basename, exists, expanduser, isdir, isfile, join, splitext

import rarfile

from couleurs import *

DISPLAY = ':0'
OLDDISPLAY = ':0'

if 'DISPLAY' in os.environ:
    OLDDISPLAY = os.environ['DISPLAY']
    DISPLAY = OLDDISPLAY
else:
    print 'Pas de $DISPLAY… Ça va être tendu pour lire des images'
    exit()

if isfile(expanduser('~/.display')):
    with open(expanduser('~/.display')) as f:
        DISPLAY = f.read().strip()

TOME_RE = re.compile('Tome ', re.I)
BADARCH = re.compile('\.\./|^/')

DL_PATH = expanduser('~/Downloads')
SCAN_PATH = expanduser('~/Scans')
LECT_PATH = expanduser('~/Lecture')

USELESS_FILES = ['.directory', 'Thumbs.db', '._.BridgeSort', '._.DS_Store']
USELESS_DIRS = ['__MACOSX']

NOT_SCANS_EXTENSIONS = ['.mp4', '.torrent']

SCANS = os.listdir(SCAN_PATH)

if 'Divers' in SCANS:
    SCANS.remove('Divers')

r = SCANS[0]
for scan in SCANS[1:]:
    r = r + '|' + scan

SERIES = {}
SERIES_RE = re.compile(r.replace(' ', '.?'), re.I)
CHAPITRES_TELECHARGES = []

TC = ['chapitres', 'tomes']
MP = ['presents', 'manquants']
AL = ['lus', 'a_lire']

JS = {
    'Kenichi': True,
    'One Piece': False,
    'Naruto': False,
    'Fairy Tail': False,
    'Black Butler': False,
    'Claymore': False,
    'Bakuman': False,
    'Air Gear': False
}

JS_DOWN = 'http://www.japan-shin.com/lectureenligne/reader/download/<serie>/fr/<tome>/<chapitre>/'


class SerieProperty(object):
    """ Classe remplançant la fonction buildin «property»,
    histoire d’éviter la duplication de code.
    Largement copié collé de http://stackoverflow.com/questions/1380566/can-i-add-parameters-to-a-python-property-to-reduce-code-duplication
    TODO: le setter marchp pas du tout, le reste du programme appelle directement _setter c’est dégueu :/"""
    def __init__(self, tc, mp, al):
        self.tc = tc
        self.mp = mp
        self.al = al

    def __get__(self, obj, objtype):
        return Serie._getter(obj, self.tc, self.mp, self.al)

    def __set__(self, obj, val):
        print 'TATA'
        Serie._setter(obj, val, 0, self.tc, self.mp, self.al)


class SerieException(Exception):
    """Une exception sans grandes prétentions, si ce n’est d’être exceptionnelle"""
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return self.message


class Serie:
    """classe «bibliothèque» contenant les infos sur les séries: tomes et chapitres,
    lus et non lus, présents et manquants"""
    chapitres = SerieProperty('chapitres', 'presents', 'lus')
    tomes = SerieProperty('tomes', 'presents', 'lus')
    chapitres_manquants = SerieProperty('chapitres', 'manquants', 'lus')
    tomes_manquants = SerieProperty('tomes', 'manquants', 'lus')
    chapitres_a_lire = SerieProperty('chapitres', 'presents', 'a_lire')
    tomes_a_lire = SerieProperty('tomes', 'presents', 'a_lire')
    chapitres_manquants_a_lire = SerieProperty('chapitres', 'manquants', 'a_lire')
    tomes_manquants_a_lire = SerieProperty('tomes', 'manquants', 'a_lire')
    chapitres_et_tomes = SerieProperty('chapitres_et_tomes', 'presents', 'lus')
    chapitres_et_tomes_a_lire = SerieProperty('chapitres_et_tomes', 'presents', 'a_lire')
    chapitres_et_tomes_manquants = SerieProperty('chapitres_et_tomes', 'manquants', 'lus')
    chapitres_et_tomes_manquants_a_lire = SerieProperty('chapitres_et_tomes', 'manquants', 'a_lire')

    def __init__(self, path, classer=False):
        """Va chercher tous chapitres et tomes présents dans le répertoire SCAN_PATH/<serie>
        Vérifie les chapitres manquants, et peut classer les chapitres dans les tomes pour des
        cas simples"""
        self.titre = ''
        if isdir(path):
            self.titre = basename(path)
        else:
            self.titre = path
            path = join(SCAN_PATH, path)
        self.re = re.compile(self.titre.replace(' ', '.?'), re.I)
        self._data = {}
        self.lecture_ready = False

        for tc in TC:
            for mp in MP:
                for al in AL:
                    self._data[(tc, mp, al)] = []

        for dossier in os.listdir(path):
            if isdir(join(path, dossier)) and dossier != 'HS':
                if TOME_RE.search(dossier):
                    self._setter(join(path, dossier), tc='tomes')
                else:
                    self._setter(join(path, dossier))
            elif not isdir(join(path, dossier)):
                rouge('fichier: %s' % dossier)

        if self._data[('tomes', 'presents', 'lus')]:
            self._data[('tomes', 'presents', 'lus')].sort()
        if self._data[('chapitres', 'presents', 'lus')]:
            self._data[('chapitres', 'presents', 'lus')].sort()

        Serie.check(self)
        if self._data[('tomes', 'manquants', 'lus')]:
            self._data[('tomes', 'manquants', 'lus')].sort()
        if self._data[('chapitres', 'manquants', 'lus')]:
            self._data[('chapitres', 'manquants', 'lus')].sort()

        if classer:
            Serie.classer(self)

    def __str__(self):
        return self.titre

    def __repr__(self):
        return self._data

    def _setter(self, num_or_path, tome_num=0, tc='chapitres', mp='presents', al='lus'):
        """Le setter universel des données de la série"""
        is_dir = False
        if not isinstance(num_or_path, int) and isdir(num_or_path):
            is_dir = True
        elif not isinstance(num_or_path, int):
            raise TypeError('le %s «%s» doit être un dossier ou un entier' % (tc.replace('s', ''), num_or_path))
        tc_num = 0
        if is_dir:
            tc_num = int(re.findall(r'\d+', basename(num_or_path))[0])
        else:
            tc_num = num_or_path
        if tc == 'tomes':
            if is_dir:
                for dossier in os.listdir(num_or_path):
                    if isdir(join(num_or_path, dossier)):
                        self._setter(join(num_or_path, dossier), tc_num, al=al)
            if tc_num in self._data[(tc, mp, al)]:
                raise SerieException('%s est déjà dans les %s %s %s' % (num_or_path, tc, mp, al.replace('a_', 'à ')))
        else:
            #TODO: on peut déduire le tome avec des regex \o/
            if tc_num in [i for i, j in self._data[(tc, mp, al)]]:
                raise SerieException('%s est déjà dans les %s %s %s' % (num_or_path, tc, mp, al.replace('a_', 'à ')))
            tc_num = (tc_num, tome_num)
        self._data[tc, mp, al].append(tc_num)

    def _getter(self, tc='chapitres', mp='presents', al='lus'):
        """Le getter universel des données de la série"""
        if tc == 'chapitres':
            return [i for i, j in self._data[(tc, mp, al)]]
        if tc == 'chapitres_et_tomes':
            tc = 'chapitres'
        return self._data[(tc, mp, al)]

    def check(self, al='lus', affichage=True):
        """Fonction qui vérifie les données de la série à la recherche de tomes ou de chapitres manquants.
        Peut être invoquée pour les scans lus (par défaut), ou ceux qui viennent d’être téléchargés (al='a_lire')"""
        ret = True
        for tc in TC:
            if self._data[(tc, 'presents', al)]:
                presents = self._getter(tc, 'presents', al)
                if al == 'a_lire':
                    presents = presents + self._getter(tc, 'presents', 'lus')
                min_tc = min(presents)
                max_tc = max(presents)
                length = len(presents)
                if length < (max_tc - min_tc + 1):
                    ret = False
                    for i in range(min_tc, max_tc):
                        if not i in presents:
                            self._setter(i, tc=tc, mp='manquants', al=al)
        if al == 'a_lire':
            for chapitre_a_lire in self.chapitres_a_lire:
                if chapitre_a_lire in self.chapitres:
                    tome_du_chapitre_a_lire = self.tome_du_chapitre(chapitre_a_lire, 'a_lire')
                    if tome_du_chapitre_a_lire != 0 and tome_du_chapitre_a_lire != self.tome_du_chapitre(chapitre_a_lire, 'lus'):
                        jaune('Tome du chapitre lu %s de %s Trouvé (%s)! Déplacement du «lu» et suppression du «à lire»' %
                            (chapitre_a_lire, self.titre, tome_du_chapitre_a_lire))
                        src = join(SCAN_PATH, self.titre, str(chapitre_a_lire))
                        dst = join(SCAN_PATH, self.titre, 'Tome %s' % tome_du_chapitre_a_lire, str(chapitre_a_lire))
                        # TODO: tester, je viens de rajouter chapitre_a_lire
                        sup = join(LECT_PATH, self.titre, 'Tome %s' % tome_du_chapitre_a_lire, str(chapitre_a_lire))
                        if exists(src) and exists(sup):
                            shutil.move(src, dst)
                            shutil.rmtree(sup)
                        else:
                            rouge('Ou pas: «%s» ou «%s» n’existe pas' % (src, sup))
                    else:
                        jaune('Le chapitre à lire %s de %s est déjà lu… Suppression du «à lire» !' % (chapitre_a_lire, self.titre))
                        path = ''
                        if tome_du_chapitre_a_lire == 0:
                            path = join(LECT_PATH, self.titre, str(chapitre_a_lire))
                        else:
                            path = join(LECT_PATH, self.titre, 'Tome %s' % tome_du_chapitre_a_lire, str(chapitre_a_lire))
                        if exists(path):
                            shutil.rmtree(path)
                        else:
                            rouge('Ou pas: %s n’est pas un répertoire :(' % path)
        if affichage:
            if ret:
                vert('Checked !')
            else:
                rouge('Check failed…')
        return ret

    def tome_du_chapitre(self, chapitre, al='lus'):
        """Va chercher le tome correspondant au chapitre, lu ou non, s’il est connu"""
        for i, j in self._data[('chapitres', 'presents', al)]:
            if i == chapitre:
                return j
        for i, j in self._data[('chapitres', 'manquants', al)]:
            if i == chapitre:
                raise ValueError('Le chapitre %s est présent dans la liste des chapitres %s manquants….' % (chapitre, al.replace('a_', 'à ')))
        raise ValueError('Le chapitre %s n’est même pas présent dans la liste des chapitres %s manquants…. Faut lancer Serie.check() !' %
            (chapitre, al.replace('a_', 'à ')))

    def deduire_tome(self, chapitre):
        """Trouve le tome d’un chapitre, (lu…) dans les cas simples"""
        p = chapitre  # chapitre précédent
        n = chapitre  # chapitre suivant
        tp = 0  # tome du chapitre précédent
        tn = 0
        while p >= min(self.chapitres):
            p -= 1
            if p in self.chapitres and Serie.tome_du_chapitre(self, p) != 0:
                tp = Serie.tome_du_chapitre(self, p)
                break
        while n <= max(self.chapitres):
            n += 1
            if n in self.chapitres and Serie.tome_du_chapitre(self, n) != 0:
                tn = Serie.tome_du_chapitre(self, n)
                break
        if tn == 0 and self.chapitres_a_lire:
            n = chapitre
            while n <= max(self.chapitres_a_lire):
                n += 1
                if n in self.chapitres_a_lire and Serie.tome_du_chapitre(self, n, 'a_lire') != 0:
                    tn = Serie.tome_du_chapitre(self, n, 'a_lire')
                    break
        if tp == tn:
            return tp
        elif tp == tn - 1:
            return (tp, tn)
        else:
            return 0

    def classer(self):
        """Cherche d’éventuels tomes déduis et s’il en trouve, déplace les chapitres orphelins dans ces tomes déduis
        ATTENTION: C’est long !"""
        tomes = [j for i, j in self.chapitres_et_tomes]
        if tomes:
            if min(tomes) == max(tomes):
                if min(tomes) != 0:
                    k = min(tomes)
                    for i, j in self.chapitres_et_tomes:
                        if j == 0:
                            src = join(SCAN_PATH, self.titre, str(i))
                            if isdir(src):
                                dst = join(SCAN_PATH, self.titre, 'Tome ' + str(k))
                                if isdir(dst):
                                    jaune(src + ' va dans ' + dst)
                                    shutil.move(src, dst)
                                else:
                                    rouge('%s n’est pas un répertoire de destination' % dst)
                            else:
                                rouge('%s n’est pas un répertoire source' % src)

            else:
                for i, j in self.chapitres_et_tomes:
                    if j == 0:
                        k = self.deduire_tome(i)
                        if isinstance(k, int) and k > 0:
                            src = join(SCAN_PATH, self.titre, str(i))
                            if isdir(src):
                                dst = join(SCAN_PATH, self.titre, 'Tome ' + str(k))
                                if isdir(dst):
                                    jaune(src + ' va dans ' + dst)
                                    shutil.move(src, dst)
                                else:
                                    rouge('%s n’est pas un répertoire de destination' % dst)
                            else:
                                rouge('%s n’est pas un répertoire source' % src)

    def check_preparation(self):
        """Fonction similaire à l’__init__, mais pour des données pas encore lues"""
        for dossier in os.listdir(join(LECT_PATH, self.titre)):
            if isdir(join(LECT_PATH, self.titre, dossier)) and dossier != 'HS':
                if TOME_RE.search(dossier):
                    self._setter(join(LECT_PATH, self.titre, dossier), tc='tomes', mp='presents', al='a_lire')
                else:
                    self._setter(join(LECT_PATH, self.titre, dossier), tc='chapitres', mp='presents', al='a_lire')

        self.check(al='a_lire')

        for tc in TC:
            for mp in MP:
                self._data[(tc, mp, 'a_lire')] = []

        for dossier in os.listdir(join(LECT_PATH, self.titre)):
            if isdir(join(LECT_PATH, self.titre, dossier)) and dossier != 'HS':
                if TOME_RE.search(dossier):
                    self._setter(join(LECT_PATH, self.titre, dossier), tc='tomes', mp='presents', al='a_lire')
                else:
                    self._setter(join(LECT_PATH, self.titre, dossier), tc='chapitres', mp='presents', al='a_lire')
            elif not isdir(join(LECT_PATH, dossier)):
                rouge('fichier: %s' % dossier)

        if self._data[('tomes', 'presents', 'a_lire')]:
            self._data[('tomes', 'presents', 'a_lire')].sort()
        if self._data[('chapitres', 'presents', 'a_lire')]:
            self._data[('chapitres', 'presents', 'a_lire')].sort()

        self.check(al='a_lire', affichage=False)

        if self._data[('tomes', 'manquants', 'a_lire')]:
            self._data[('tomes', 'manquants', 'a_lire')].sort()
        if self._data[('chapitres', 'manquants', 'a_lire')]:
            self._data[('chapitres', 'manquants', 'a_lire')].sort()

    def reset_preparation(self):
        """Supprime les données issues d’une préparation antérieure"""
        for tc in TC:
            self._data[(tc, 'presents', 'a_lire')] = []


class Chapitre:
    """classe des informations trouvées sur les fichiers qui viennent d’être téléchargés"""
    def __init__(self, fichier, SERIES):
        self.serie = ''
        self.tome = 0
        self.chapitre = 0
        self.is_zip = False
        self.is_rar = False
        self.dossier = False
        self.path = ''
        for s in SERIES:
            if SERIES[s].re.search(fichier):
                self.serie = SERIES[s]
                fichier_path = join(DL_PATH, fichier)
                self.path = fichier_path
                if isdir(fichier_path):
                    self.dossier = True
                elif zipfile.is_zipfile(fichier_path):
                    self.is_zip = True
                elif rarfile.is_rarfile(fichier_path):
                    self.is_rar = True
                else:
                    raise TypeError('%s n’est ni un zip, ni un rar, ni un dossier…' % fichier_path)
                tomes = re.findall('(?<=[Tt]ome)\d+|(?<=[Tt]ome)\d+|(?<=v)\d+', fichier)
                chapitres = re.findall('(?<=c)\d+', fichier)
                if not tomes and not chapitres:
                    chapitres = re.findall('\d+', fichier)
                if not tomes:
                    self.tome = 0
                elif len(tomes) == 1:
                    self.tome = tomes[0]
                else:
                    raise ValueError('Plusieurs tomes possibles dans %s : %s' % (fichier, tomes))
                if len(chapitres) == 1:
                    self.chapitre = chapitres[0]
                else:
                    raise ValueError('Parsage de chapitre raté dans %s' % fichier)
                if self.chapitre in SERIES[s].chapitres:
                    rouge('Ce chapitre a déjà été lu : ' + self.__repr__())

    def __repr__(self):
        if self.tome:
            return 'Chapitre n°%s du tome %s de %s.' % (self.chapitre, self.tome, self.serie)
        else:
            return 'Chapitre n°%s de %s.' % (self.chapitre, self.serie)


def trouver_series(classer=False, affichage=False):
    """Fonction qui lance bêtement tous les __init__ nécessaires de Serie et donnes des infos à ce propos"""
    for dossier in SCANS:
        sys.stdout.write('\n • ' + dossier + ' ')
        SERIES[dossier] = Serie(join(SCAN_PATH, dossier), classer)
        if affichage:
            if SERIES[dossier].tomes_manquants:
                rouge('Tomes manquants:')
                print SERIES[dossier].tomes_manquants
            if SERIES[dossier].chapitres_manquants:
                rouge('Chapitres manquants:')
                print SERIES[dossier].chapitres_manquants


def traiter_dl():
    """Fonction qui regarde les fichiers dans DL_PATH à la recherche de nouveaux chapitres"""
    doublon_re = re.compile(' \(\d\)')
    fichiers = os.listdir(DL_PATH)
    rien_a_voir = []
    for fichier in fichiers:
        if SERIES_RE.search(fichier) and splitext(fichier)[1] not in NOT_SCANS_EXTENSIONS:
            est_unique = True
            if doublon_re.search(fichier):
                doublon = join(DL_PATH, fichier)
                source = join(DL_PATH, re.sub(' \(\d\)', '', fichier))
                if exists(source):
                    if filecmp.cmp(source, doublon):
                        est_unique = False
                        jaune(fichier + ' est un doublon, on le supprime')
                        os.remove(doublon)
            if est_unique:
                CHAPITRES_TELECHARGES.append(Chapitre(fichier, SERIES))
        else:
            rien_a_voir.append(fichier)
    if rien_a_voir:
        rouge('Rien à voir: ' + ', '.join(rien_a_voir))


def nettoyer(path):
    """Fonction qui enlève les fichiers et dossiers inutiles récursivement dans path"""
    for dirpath, dirnames, filenames in os.walk(path):
        for useless_dir in USELESS_DIRS:
            if useless_dir in dirnames:
                jaune('Suppression RÉCURSIVE de %s/%s' % (dirpath, useless_dir))
                shutil.rmtree(join(dirpath, useless_dir))
        for useless_file in USELESS_FILES:
            if useless_file in filenames:
                jaune('Suppression de %s/%s' % (dirpath, useless_file))
                os.remove(join(dirpath, useless_file))
    for dirpath, dirnames, filenames in os.walk(path):
        if not dirnames and not filenames and not dirpath in [DL_PATH, LECT_PATH, SCAN_PATH]:
            jaune('Suppression récursive inverse de %s' % dirpath)
            os.removedirs(dirpath)


def preparer_chapitres():
    """Fonction qui prépare les chapitrse trouvés par traiter_dl à la lecture"""
    for c in CHAPITRES_TELECHARGES:
        path = ''
        if c.tome == 0:
            path = join(LECT_PATH, c.serie.titre, c.chapitre)
        else:
            path = join(LECT_PATH, c.serie.titre, 'Tome ' + c.tome, c.chapitre)
        os.makedirs(path)
        if c.is_zip:
            z = zipfile.ZipFile(c.path)
            extract = True
            if z.testzip():
                extract = False
                rouge('Zip corrompu: ' + path)
            fichiers = z.namelist()
            for fichier in fichiers:
                if BADARCH.search(fichier):
                    rouge('Zip vicieu: ' + fichier)
                    extract = False
            if extract:
                z.extractall(path)
                files = os.listdir(path)
                if len(files) == 1 and isdir(join(path, files[0])):
                    subfiles = os.listdir(join(path, files[0]))
                    for subfile in subfiles:
                        shutil.move(join(path, files[0], subfile), path)
            z.close()
            os.remove(c.path)
        elif c.is_rar:
            r = rarfile.RarFile(c.path)
            extract = True
            if r.testrar():
                extract = False
                rouge('Rar corrompu: ' + path)
            fichiers = r.namelist()
            for fichier in fichiers:
                if BADARCH.search(fichier):
                    extract = False
                    rouge('Rar vicieu: ' + fichier)
            if extract:
                r.extractall(path)
                files = os.listdir(path)
                if len(files) == 1 and isdir(join(path, files[0])):
                    subfiles = os.listdir(join(path, files[0]))
                    for subfile in subfiles:
                        shutil.move(join(path, files[0], subfile), path)
            r.close()
            os.remove(c.path)
        elif c.dossier:
            fichiers = os.listdir(c.path)
            for f in fichiers:
                shutil.move(join(c.path, f), path)
            shutil.rmtree(c.path)
        else:
            rouge('FAIL')
        vert(' • Traité: ' + c.__repr__())
    nettoyer(LECT_PATH)
    nettoyer(DL_PATH)
    del CHAPITRES_TELECHARGES[:]


def check_preparation():
    """Fonction qui vérifie que les chapitres prêts pour la lecture sont bons"""
    for dossier in os.listdir(LECT_PATH):
        sys.stdout.write('\n • ' + dossier + ' ')
        SERIES[dossier].check_preparation()
        SERIES[dossier].lecture_ready = True
        if SERIES[dossier].tomes_manquants_a_lire and SERIES[dossier].tomes_manquants_a_lire[-1] > SERIES[dossier].tomes[-1]:
            rouge('Tomes manquants à lire:')
            print SERIES[dossier].tomes_manquants_a_lire
            SERIES[dossier].lecture_ready = False
        if SERIES[dossier].chapitres_manquants_a_lire and SERIES[dossier].chapitres:
            if SERIES[dossier].chapitres_manquants_a_lire[-1] > SERIES[dossier].chapitres[-1]:
                rouge('Chapitres manquants à lire:')
                print SERIES[dossier].chapitres_manquants_a_lire
                jaune('\tDernier chapitre présent lu de %s: %s' % (dossier, SERIES[dossier].chapitres[-1]))
                SERIES[dossier].lecture_ready = False


def telecharger_missing(bloquants_only=True):
    """ Télécharge automatiquement les chapitres qui manquent """
    yenavait = False
    os.putenv('DISPLAY', DISPLAY)
    for s in SERIES:
        if s in JS.keys():
            titre = SERIES[s].titre
            titre = titre.lower()
            titre = titre.replace(' ', '_')
            chapitres_et_tomes_manquants = SERIES[s].chapitres_et_tomes_manquants + SERIES[s].chapitres_et_tomes_manquants_a_lire
            if bloquants_only:
                c = []
                try:
                    dernier_lu = SERIES[s].chapitres[-1]
                except IndexError:
                    dernier_lu = 0
                for i in chapitres_et_tomes_manquants:
                    if i[0] > dernier_lu:
                        c.append(i)
                chapitres_et_tomes_manquants = c
            for c, t in chapitres_et_tomes_manquants:
                if not JS[s]:
                    webbrowser.open(JS_DOWN.replace('<serie>', titre).replace('<tome>', '0').replace('<chapitre>', str(c)))
                    yenavait = True
                    time.sleep(5)
                elif t == 0:
                    t = SERIES[s].deduire_tome(c)
                    if isinstance(t, int):
                        webbrowser.open(JS_DOWN.replace('<serie>', titre).replace('<tome>', str(t)).replace('<chapitre>', str(c)))
                    else:
                        webbrowser.open(JS_DOWN.replace('<serie>', titre).replace('<tome>', str(t[0])).replace('<chapitre>', str(c)))
                        webbrowser.open(JS_DOWN.replace('<serie>', titre).replace('<tome>', str(t[1])).replace('<chapitre>', str(c)))
                    yenavait = True
                    time.sleep(5)
                else:
                    rouge('TODO2')
    return yenavait


def question(txt, default=True):
    txt += " [O/n] " if default else " [o/N] "
    i = raw_input(txt).upper()
    if i == 'O':
        return True
    if i == 'N':
        return False
    return default


def lecture():
    """ La seule et véritable utilité de ce script est de LIRE \o/"""
    path = ''
    os.putenv('DISPLAY', OLDDISPLAY)
    for s in os.listdir(LECT_PATH):
        vert('\n • ' + s + ' ')
        for c, t in SERIES[s].chapitres_et_tomes_a_lire:
            if t:
                path = join(LECT_PATH, s, 'Tome %s' % t, str(c))
            else:
                path = join(LECT_PATH, s, str(c))
            print '\t', path
            if isdir(path):
                os.system("eog -f '%s'" % path)
                if question("Ranger le chapitre qui vient d’être lu ?"):
                    dst = ''
                    if t:
                        dst = join(SCAN_PATH, s, 'Tome %s' % t)
                    else:
                        dst = join(SCAN_PATH, s)
                    if not isdir(dst):
                        os.mkdir(dst)
                    vert("%s => %s" % (path, dst))
                    shutil.move(path, dst)
            else:
                rouge('«%s» n’est pas un dossier oO' % path)


def reset_preparation():
    """Vide la liste des trucs présentes dans les chapitres/tomes à lire """
    for dossier in os.listdir(LECT_PATH):
        SERIES[dossier].reset_preparation()

if __name__ == '__main__':
    jaune('−' * 24 + ' Vérification des scans présents… ' + '−' * 22)
    trouver_series(classer=False, affichage=False)
    if isdir(LECT_PATH):
        print
        jaune('−' * 18 + ' Vérification de la préparation précédente… ' + '−' * 18)
        print
        preparer_chapitres()
    print
    jaune('−' * 24 + ' Traitement des téléchargements… ' + '−' * 23)
    print
    if not isdir(DL_PATH):
        os.mkdir(DL_PATH)
    traiter_dl()
    print
    jaune('−' * 24 + ' Préparation des chapitres… ' + '−' * 28)
    print
    preparer_chapitres()
    print
    jaune('−' * 24 + ' Vérification de la préparation… ' + '−' * 23)
    print
    if not isdir(LECT_PATH):
        os.mkdir(LECT_PATH)
    check_preparation()
    print
    jaune('−' * 24 + ' Téléchargement des manquants… ' + '−' * 25)
    print
    if telecharger_missing(bloquants_only=True):
        print
        print 'On attend une petite minute que les DLs se finissent…'
        time.sleep(60)
        print
        jaune('−' * 24 + ' Traitement des téléchargements… ' + '−' * 23)
        print
        if not isdir(DL_PATH):
            os.mkdir(DL_PATH)
        traiter_dl()
        print
        jaune('−' * 24 + ' Préparation des chapitres… ' + '−' * 28)
        print
        preparer_chapitres()
        print
        jaune('−' * 24 + ' Vérification de la préparation… ' + '−' * 23)
        print
        if not isdir(LECT_PATH):
            os.mkdir(LECT_PATH)
        reset_preparation()
        check_preparation()
        print

    print
    jaune('−' * 24 + ' Lecture… ' + '−' * 46)
    print
    lecture()
    jaune('−' * 24 + ' Nettoie… ' + '−' * 46)
    nettoyer(LECT_PATH)
