Unit unite;


Interface

Const MAX = 50;

Type Enviro = (Manoir, INSA);

Type ListeCartes = (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Studio, Hall, Monsieur_Bredel, Madame_LArcheveque, Le_Directeur, Yohann_Lepailleur, Infirmiere, Seringue, Moteur_4_temps, Alteres, Flacon_Acide, Ordi, Pouf_Rouge, Cafete, Amphi_Tillon, Infirmerie, Vestiaires, Labo, DUBRJ11, Bureau_du_directeur, Toilettes, BU);

Type Coords = Array [1..2] of Integer;

Type Joueur = record
    enVie : Boolean;
	cartes : set of ListeCartes;
	pos : Coords;
	perso : ListeCartes;
end;

Type ListeJoueurs = Array of Joueur;

Type Salle = Array [1..25] of Coords;

Type Plateau = record 
    grille : Array [0..MAX,0..MAX] of Integer;
    salles : Array [1..9] of Salle;
end;


Implementation


end.
