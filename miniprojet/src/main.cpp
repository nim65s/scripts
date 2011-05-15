#include <iostream>
#include <cstdio>

using namespace std;

class vecteur {
    public:
    int n;
    float coef[100];
    void afficher() {
        cout << "[";
        for(int i=0;i<n;i++) {
            printf("%5.2g",coef[i]);
            cout << " ";
        }
        cout << "  ]" << endl;
    }
};

bool operator==(vecteur a, vecteur b) {
    if (a.n != b.n) return false;
    else for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return false; // TODO ça marche ça ? x)
    return true;
}

class matricepleine {
    public:
    int n;
    int m;
    float coef[100][100]; // TODO dynamic
    void afficher() {
        cout << "⎡";
        for(int j=0;j<m;j++) printf("%5.4g ",coef[0][j]);
        cout << "  ⎤" << endl;
        for(int i=1;i<n-1;i++) {
            cout << "⎢";
            for(int j=0;j<m;j++) printf("%5.4g ",coef[i][j]);
            cout << "  ⎥" << endl;
        }
        cout << "⎣";
        for(int j=0;j<m;j++) printf("%5.4g ",coef[n-1][j]);
        cout << "  ⎦" << endl;
    }
};

bool operator==(matricepleine A, matricepleine B) {
    if( A.n != B.n || A.m != B.m) return false;
    else for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return false;
    return true;
}

vecteur operator*(matricepleine M, vecteur v) {
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<M.n;i++) {
        w.coef[i] = 0;
        for(int j=0;j<M.m;j++) w.coef[i] += v.coef[j]*M.coef[i][j];
    }
    return w;
}

class matricecreuseun {
    public:
    int m;
    int n;
    int o; // nombre de coeficients non nuls de la matrice
    int i[100]; // TODO dynamic
    int j[100];
    float coef[100]; 
    void afficher() {
        cout << "  i  | ";
        for(int k=0;k<o;k++) printf("%5d ",i[k]+1);
        cout << endl << "  j  | ";
        for(int k=0;k<o;k++) printf("%5d ",j[k]+1);
        cout << endl << "coef | ";
        for(int k=0;k<o;k++) printf("%5.4g ",coef[k]);
        cout << endl << endl;
    }
};

bool operator==(matricecreuseun A, matricecreuseun B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o) return false;
    else for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return false; // TODO Faux positifs monstrueux T-T
    /* L'idée serait de faire ce test là, et s'il ne passe pas, mettre les données de B de coté, et réessayer avec les suivantes
     * Mais c'est un poil tendu et peut être pas si pertinent que ça à coder...
     */
    return true;
}

vecteur operator*(matricecreuseun M, vecteur v) {
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w;
    w.n = M.n;
    for(int i=0;i<w.n;i++) w.coef[i] = 0;
    for(int k=0;k<M.o;k++) w.coef[M.i[k]] += M.coef[k]*v.coef[M.j[k]];
    return w;
}

matricecreuseun pleineversun(matricepleine A) {
    matricecreuseun B;
    B.m = A.m;
    B.n = A.n;
    B.o = 0;
    for(int i=0;i<A.m;i++) {
        for(int j=0;j<A.n;j++) {
            if (A.coef[i][j] != 0) {
                B.i[B.o] = i;
                B.j[B.o] = j;
                B.coef[B.o] = A.coef[i][j];
                B.o++;
            }
        }
    }
    return B;
}

class matricecreusedeux {
    public:
    int m;
    int n;
    int o; // peut se déduire vu que la matrice est crueuse...
    int p; // nombre de valeurs dans le tableau II
    float vals[100]; 
    int j[100]; // TODO dynamic
    int II[100];
    void afficher() {
        cout << "vals | ";
        for(int k=0;k<o;k++) printf("%5.4g ",vals[k]);
        cout << endl << "  j  | ";
        for(int k=0;k<o;k++) printf("%5d ",j[k]+1);
        cout << endl << " II  | ";
        for(int k=0;k<p;k++) printf("%5d ",II[k]);
        cout << endl << endl;
    }
};

bool operator==(matricecreusedeux A, matricecreusedeux B) {
    if (A.m != B.m || A.n != B.n || A.o != B.o || A.p != B.p) return false;
    else {
        for (int k=0;k<A.o;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return false;
        for (int k=0;k<=A.p;k++) if (A.II[k] != B.II[k]) return false;
    }
    return true;
}

vecteur operator*(matricecreusedeux A, vecteur v) {
    return v;// TODO
}

matricecreusedeux pleineversdeux(matricepleine A) {
    matricecreusedeux B;
    B.m = A.m;
    B.n = A.n;
    B.o = 0;
    B.p = 0;
    int cmpt = 0;
    for (int i=0;i<A.m;i++) {
        bool yadejaqqchsurlaligne = false;
        for(int j=0;j<A.n;j++) {
            if(A.coef[i][j] != 0) {
                B.vals[B.o] = A.coef[i][j];
                B.j[B.o++] = j;
                cmpt++; // TODO décalage vu qu'un tableau commence à 0 ?
                if (!yadejaqqchsurlaligne) {
                    yadejaqqchsurlaligne = true;
                    B.II[B.p++] = cmpt;
                }
            }
        }
        if (!yadejaqqchsurlaligne) B.II[B.p++] = 0; // TODO si la ligne est vide ?
    }
    B.II[B.p++] = B.II[0]+B.o;// TODO faudra qu'on m'explique à quoi il sert lui... 
    return B;
}

int main() {
    cout << "Mini Projet" << endl;
    matricepleine A;
    A.m = 5;
    A.n = 5;
    for(int i=0;i<5;i++) A.coef[i][i] = i;
    A.afficher();

    vecteur v;
    v.n = 5;
    for(int i=0;i<5;i++) v.coef[i] = i;
    v.afficher();

    vecteur w;
    w = A*v;
    w.afficher();

    matricepleine B;
    B.m = 5;
    B.n = 5;
    B.coef[0][0] = 1.1;
    B.coef[0][3] = 4;
    B.coef[1][0] = 5;
    B.coef[1][1] = 2.2;
    B.coef[1][3] = 7;
    B.coef[2][0] = 6;
    B.coef[2][2] = 3.3;
    B.coef[2][3] = 8;
    B.coef[2][4] = 9;
    B.coef[3][2] = 11;
    B.coef[3][3] = 10.1;
    B.coef[4][4] = 12.7;
    B.afficher();

    matricecreuseun C;
    C = pleineversun(B);
    C.afficher();

    matricecreusedeux D;
    D = pleineversdeux(B);
    D.afficher();
}
