#include <iostream>
#include <cstdio>
#include <string>
#include <assert.h>
#include <math.h>
#include "matrices.h"
#include "fichiers.h"

using namespace std;

matricecreuseun lireun(string const & file, bool const & comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe coef;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreuseun M(m, n, nz);
    for(int k(0); k<nz; k++) {
        if(comp) fscanf(t, "%d %d %lf %lf", &M.i[k], &M.j[k], &M.coef[k].re, &M.coef[k].im);
        else fscanf(t, "%d %d %lf", &M.i[k], &M.j[k], &M.coef[k].re);
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreuseun const & A, string const & file) {{{
    FILE * t; // TODO Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k(0); k<A.nz; k++) fprintf(t, "%d %d %lf %lf\n", A.i[k], A.j[k], A.coef[k].re, A.coef[k].im);
    fclose(t);
    return 0;
}}}

matricecreusedeux liredeux(string const & file, bool const & comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe vals;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreusedeux M(m, n, nz);
    for(int k(0); k<=m; k++) fscanf(t, "%d", &M.II[k]);
    for(int k(0); k<nz; k++) {
        if(comp) fscanf(t, "%d %lf %lf", &M.j[k], &M.vals[k].re, &M.vals[k].im);
        else fscanf(t, "%d %lf", &M.j[k], &M.vals[k].re);
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreusedeux const & A, string const & file) {{{
    FILE * t; // TODO Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k(0); k<=A.m; k++) fprintf(t, "%d\n", A.II[k]);
    for(int k(0); k<A.nz; k++) fprintf(t, "%d %lf %lf\n", A.j[k], A.vals[k].re, A.vals[k].im);
    fclose(t);
    return 0;
}}}

string demandernomdufichier() {{{
    string a, b, c, d, e, f;
    char rep;
    a = "../test.mx";
    b = "../A398.mx";
    c = "../A62.mx";
    d = "../B398.mx";
    e = "../B62.mx";
    f = "En entrer un autre";
    cout << "Quel fichier voulez vous lire ?" << endl;
    cout << "a) " << a << endl;
    cout << "b) " << b << endl;
    cout << "c) " << c << endl;
    cout << "d) " << d << endl;
    cout << "e) " << e << endl;
    cout << "f) " << e << endl;
    cout << "==> ";
    cin >> rep;
    string choix; // TODO l'idée était de faire un * choix...
    switch (rep) {
        case 'a':
            choix = a;
            break;
        case 'b':
            choix = b;
            break;
        case 'c':
            choix = c;
            break;
        case 'd':
            choix = d;
            break;
        case 'e':
            choix = d;
            break;
        case 'f':
            cin >> choix;
            break;
        default :
            assert(false);
            break;
    }
    return choix;
}}}

matricecreuseun lireun(bool const & comp) {{{
    //string nom = demandernomdufichier();
    //return lireun(nom, comp);
    return lireun(demandernomdufichier(), comp);
}}}

int ecrire(matricecreuseun const & A) {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(A, nom);
}}}

matricecreusedeux liredeux(bool const & comp) {{{
    //string nom = demandernomdufichier();
    //return liredeux(nom, comp);
    return liredeux(demandernomdufichier(), comp);
}}}

int ecrire(matricecreusedeux const & A) {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(A, nom);
}}}

// vim: set foldmethod=marker:
