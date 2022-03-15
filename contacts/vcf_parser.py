#!/usr/bin/env python

from pathlib import Path

from vcards import Vcard


def import_ab(filename):
    vcards = {}
    started = False
    content = []
    with open(filename, "r") as f:
        lines = f.read().replace("\n ", "").replace("\n\t", "").split("\n")

    for line in lines:
        ls = line.strip()
        if ls == "BEGIN:VCARD":
            started = True
        elif ls == "END:VCARD":
            started = False
            v = Vcard(filename.replace(".vcf", ""), content)
            vcards[v.uid] = v
            content = []
        elif started:
            content.append(ls.split(":", 1))
    return vcards


def export_ab(vcards, filename):
    with open(filename, "w") as f:
        print("BEGIN:VADDRESSBOOK", file=f)
        for vcard in vcards.values():
            print(vcard.fmt(), file=f)
        print("END:VADDRESSBOOK", file=f)


def ab_diff(a, b):
    ai, bi = import_ab(a), import_ab(b)
    if len(ai) != len(bi):
        print(f"{a} a %n éléments et {b} %n" % (len(ai), len(bi)))
        return False
    ret = True
    for uid in ai.keys():
        if ai[uid] != bi[uid]:
            ret = False
            vcard_diff(ai[uid], bi[uid])
    return ret


def vcard_diff(a, b):
    print("diff", a, b)
    if a.dict.keys() != b.dict.keys():
        print("pas les mêmes clefs:", a.dict.keys(), b.dict.keys())


if __name__ == "__main__":
    for vcf in Path(".").glob("*.vcf"):
        vcards = import_ab(str(vcf))
        export_ab(vcards, vcf.stem + "_generated")
        print(vcf, ab_diff(str(vcf), vcf.stem + "_generated"))
    if ab_diff("Fusion.vcf", "saved_Fusion.vcf"):
        print("Fusion == saved_Fusion")
