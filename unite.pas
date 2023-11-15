Unit unite;


Interface

Const 
    MAX = 50;
    UP = #72;
	DOWN = #80;
	LEFT = #75;
	RIGHT = #77;
    QUIT = #113;
    SPACE = #32;

Type Enviro = (Manoir, INSA);

Type ListeCartes = (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Professeur_Violet, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Hall, Studio, Cluedo, Monsieur_Bredel, Madame_LArcheveque, Le_Directeur, Yohann_Lepailleur, Monsieur_Thibault, Infirmiere, Seringue, Moteur_4_temps, Alteres, Flacon_Acide, Ordi, Pouf_Rouge, Cafete, Amphi_Tillon, Infirmerie, Bureau_directeur, Toilettes, Vestiaires, DUBRJ11, Labo, BU, Accueil);

Type Coords = Array [1..2] of Integer;

Type Joueur = record
    enVie : Boolean;
	cartes : set of ListeCartes;
	pos : Coords;
	perso : ListeCartes;
    pion : Char;
end;

Type ListeJoueurs = Array of Joueur;

Type Salle = record
    nom : ListeCartes;
    cases : Array [1..MAX] of Coords;
end;

Type Plateau = record 
    grille : Array [1..MAX,1..MAX] of Integer;
    salles : Array [1..10] of Salle;
end;


Implementation

function StrToListeCartes(carteachanger: String): ListeCartes;

begin
case carteachanger of 
    'Colonel_Moutarde' : StrToListeCartes:=Colonel_Moutarde;
    'Colonel Moutarde' : StrToListeCartes:=Colonel_Moutarde;
    'Docteur_Olive': StrToListeCartes:=Docteur_Olive;
    'Docteur Olive': StrToListeCartes:=Docteur_Olive;
    'Madame_Pervenche' : StrToListeCartes:=Madame_Pervenche;
    'Madame Pervenche' : StrToListeCartes:=Madame_Pervenche;
    'Mademoiselle_Rose': StrToListeCartes:=Mademoiselle_Rose;
    'Mademoiselle Rose': StrToListeCartes:=Mademoiselle_Rose;
    'Professeur_Violet' : StrToListeCartes:=Professeur_Violet;
    'Professeur Violet' : StrToListeCartes:=Professeur_Violet;
    'Madame_Leblanc': StrToListeCartes:=Madame_Leblanc;
    'Madame Leblanc': StrToListeCartes:=Madame_Leblanc;
    'Poignard' : StrToListeCartes:=Poignard;
    'Chandelier' : StrToListeCartes:=Chandelier;
    'Revolver': StrToListeCartes:=Revolver;
    'Corde': StrToListeCartes:=Corde;
    'Matraque' : StrToListeCartes:=Matraque;
    'Clef_Anglaise' : StrToListeCartes:=Clef_Anglaise;
    'Clef Anglaise': StrToListeCartes:=Clef_Anglaise;
    'Cuisine': StrToListeCartes:=Cuisine;
    'Grand_Salon' : StrToListeCartes:=Grand_Salon;
    'Grand Salon' : StrToListeCartes:=Grand_Salon;
    'Petit_Salon': StrToListeCartes:=Petit_Salon;
    'Petit Salon': StrToListeCartes:=Petit_Salon;
    'Salle_a_manger': StrToListeCartes:=Salle_a_manger;
    'Salle a manger': StrToListeCartes:=Salle_a_manger;
    'Bureau': StrToListeCartes:=Bureau;
    'Bibliotheque': StrToListeCartes:=Bibliotheque;
    'Veranda': StrToListeCartes:=Veranda;
    'Hall': StrToListeCartes:=Hall;
    'Studio' : StrToListeCartes:=Studio;
    'Cluedo' : StrToListeCartes:=Cluedo;
    'Monsieur_Bredel': StrToListeCartes:= Monsieur_Bredel;
    'Monsieur Bredel': StrToListeCartes:= Monsieur_Bredel;
    'Madame_LArcheveque' : StrToListeCartes:=Madame_LArcheveque;
    'Madame LArcheveque' : StrToListeCartes:=Madame_LArcheveque;
    'Le_Directeur': StrToListeCartes:=Le_Directeur;
    'Le Directeur': StrToListeCartes:=Le_Directeur;
    'Yohann_Lepailleur' : StrToListeCartes:=Yohann_Lepailleur;
    'Yohann Lepailleur' : StrToListeCartes:=Yohann_Lepailleur;
    'Monsieur_Thibault': StrToListeCartes:=Monsieur_Thibault;
    'Monsieur Thibault': StrToListeCartes:=Monsieur_Thibault;
    'Infirmiere': StrToListeCartes:=Infirmiere;
    'Seringue': StrToListeCartes:=Seringue;
    'Moteur_4_temps': StrToListeCartes:=Moteur_4_temps;
    'Alteres': StrToListeCartes:=Alteres;
    'Flacon_Acide': StrToListeCartes:=Flacon_Acide;
    'Flacon Acide': StrToListeCartes:=Flacon_Acide;
    'Ordi': StrToListeCartes:=Ordi;
    'Pouf_Rouge': StrToListeCartes:=Pouf_Rouge;
    'Pouf Rouge': StrToListeCartes:=Pouf_Rouge;
    'Cafete': StrToListeCartes:=Cafete;
    'Amphi_Tillon': StrToListeCartes:=Amphi_Tillon;
    'Amphi Tillon': StrToListeCartes:=Amphi_Tillon;
    'Infirmerie': StrToListeCartes:=Infirmerie;
    'Bureau_directeur': StrToListeCartes:=Bureau_directeur;
    'Bureau directeur': StrToListeCartes:=Bureau_directeur;
    'Vestiaires': StrToListeCartes:=Vestiaires;
    'Toilettes': StrToListeCartes:=Toilettes;
    'DUBRJ11' : StrToListeCartes:=DUBRJ11;
    'Labo': StrToListeCartes:=Labo;
    'BU': StrToListeCartes:=BU;
    'Accueil': StrToListeCartes:=Accueil;
    end;
end;

end.

