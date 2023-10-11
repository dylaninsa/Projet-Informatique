Unit unite;


Interface

Const MAX = 50;

Type Enviro = (Manoir, INSA);

Type ListeCartes = (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Studio, Hall);

Type Coords = Array [1..2] of Integer;

Type Joueur = record
    enVie : Boolean;
	cartes : set of ListeCartes;
	pos : Coords;
	perso : ListeCartes;
end;

Type ListeJoueurs = Array of Joueur;

Type Salle = Array [1..MAX*MAX] of Coords;

Type Plateau = record 
    grille : Array [0..MAX,0..MAX] of Integer;
    salles : Array [1..9] of Salle;
end;


Implementation


end.