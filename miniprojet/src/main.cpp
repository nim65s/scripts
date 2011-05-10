#include <iostream>
#include <cstdio>

using namespace std;

class vecteur {
    public:
    int n;
    float coef[100];
    void afficher() {
        cout << "[";
        for(int i=0;i<n;i++) printf("%5.2g",coef[i]);
        cout << "    ]" << endl;
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
        for(int j=0;j<m;j++) {
            printf("%5.2g",coef[0][j]);
            cout << " ";
        }
        cout << "  ⎤" << endl;
        for(int i=1;i<n-1;i++) {
            cout << "⎢";
            for(int j=0;j<m;j++) {
                printf("%5.2g",coef[i][j]);
                cout << " ";
            }
            cout << "  ⎥" << endl;
        }
        cout << "⎣";
        for(int j=0;j<m;j++) {
            printf("%5.2g",coef[n-1][j]);
            cout << " ";
        }
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
        for(int k=0;k<m;k++) printf("%5d",i[k]);
        cout << endl << "  j  | ";
        for(int k=0;k<m;k++) printf("%5d",j[k]);
        cout << endl << "coef | ";
        for(int k=0;k<m;k++) printf("%5.2g",coef[k]);
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

