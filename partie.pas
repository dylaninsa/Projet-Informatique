Unit partie;


Interface

uses unite, Crt, affichage;


procedure jeu(var etui : Array of ListeCartes; var plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro);
procedure tour(var plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);
{procedure quitterSauvegarder(joueurs:ListeJoueurs; plat:Plateau; var etui:Array of ListeCartes; var sauvegarde:File);}
procedure deplacement(var plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
procedure lancerDes(var lancer : Integer);
procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);
procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);
function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;
function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;
function joueursEnVie(joueurs : ListeJoueurs) : Integer;
function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;



Implementation


function joueursEnVie(joueurs : ListeJoueurs) : Integer;

var i : Integer;

begin
    {Renvoie le nombre de joueurs en vie}
    joueursEnVie := 0;
    for i := 0 to length(joueurs) do
        begin
            if (joueurs[i].enVie) then
                joueursEnVie := joueursEnVie + 1;
        end;
end;



procedure jeu(var etui : Array of ListeCartes; var plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro);

var j_actif : Integer;
    accusation : Boolean;
    key : Char;

begin
    {Lance le jeu}
    ClrScr;
    accusation := False;


    {Lance les tours pour chaque perso jusqu'à ce qu'on quitte ou qu'il n'y ait plus assez de joueurs en vie ou sir les éléments du meurtre ont été trouvés}
    j_actif := 1;
    repeat 
        begin 
            if (joueurs[j_actif].enVie) then
                tour(plat, etui, joueurs, accusation, j_actif, environnement);
            

            {Vérifie si la partie est finie}
            if ((joueursEnVie(joueurs) < 1) OR (accusation)) then
                begin
                    ClrScr;
                    finPartie(joueurs, accusation, j_actif, etui);
                end
            else
                begin
                    writeln('Appuyer sur ''Q'' pour quitter ou sur n''importe quelle autre touche pour continuer.');
                    key := readKey();

                    if (j_actif = length(joueurs)) then
                        j_actif := 1
                    else
                        j_actif := j_actif + 1;
                end;

        
        end;
        until ((key = QUIT) OR (joueursEnVie(joueurs) < 1) OR (accusation));
end;



function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;

var co : Coords;
    i : Integer;

begin
    {Renvoie True si le joueur est dans une salle, False sinon}
    i := 1;
    estDansSalle := False;
    repeat
        begin
            for co in plat.salles[i].cases do
                begin
                    if ((co[1] = joueurs[j_actif].pos[1]) AND (co[2] = joueurs[j_actif].pos[2])) then
                        estDansSalle := True;
                end;
            i := i + 1;
        end;
        until ((i = 11) OR estDansSalle);        

end;



function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;

var co : Coords;
    i : Integer;

begin
    {Renvoie la salle dans laquelle le joueur se trouve}
    i := 1;
    estDansLaSalle := 0;
    repeat
        begin
            for co in plat.salles[i].cases do
                begin
                    if ((co[1] = coordonnees[1]) AND (co[2] = coordonnees[2])) then
                        estDansLaSalle := i;
                end;
            i := i + 1;
        end;
        until (i = 11);        

end;



procedure tour(var plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);

var c, lancer : Integer;
    hypo : Array [1..3] of ListeCartes;
    continue : Char;

begin
    {Indique le personnage qui joue}
    ClrScr;
    write('C''est a ');
    colorPerso(joueurs, j_actif);
    write(joueurs[j_actif].perso);
    TextColor(15);
    writeln(' de jouer ! (Appuyer sur ''espace'')');
    repeat
        continue := readKey();
        until (continue = #32);


    {Affiche les cartes du joueurs qui joue}
    affichageCartes(joueurs, j_actif);
    if estDansSalle(joueurs, plat, j_actif) then
        writeln('Vous etes actuellement dans la salle : ', plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom, '.');
    writeln('(Appuyer sur ''espace'')');
    repeat
        continue := readKey();
        until (continue = #32);
    

    {Différentes action possibles selon les cas}
    if (estDansSalle(joueurs, plat, j_actif)) then
        begin
            if (estDansLaSalle(plat, joueurs[j_actif].pos) = 10) then
                begin
                    writeln('Que voulez-vous faire :');
                    writeln('   1 : Vous deplacer');
                    writeln('   2 : Formuler une accusation');  

                    repeat
                        write('Votre choix est : ');
                        readln(c);
                        if not((c >= 1) AND (c <= 2)) then
                            writeln('Ce choix est invalide.')
                        until ((c >= 1) AND (c <= 2));

                    case c of
                        1 : begin
                                lancerDes(lancer);
                                deplacement(plat, lancer, joueurs, j_actif);
                                if (estDansSalle(joueurs, plat, j_actif)) then
                                    begin
                                        ClrScr;
                                        affichageCartes(joueurs, j_actif);
                                        if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then
                                            faireHypothese(joueurs, hypo, plat, j_actif, environnement)
                                        else
                                            faireAccusation(etui, joueurs, accusation, j_actif, environnement);
                                    end;
                            end;
                        2 : begin
                                affichageCartes(joueurs, j_actif);
                                faireAccusation(etui, joueurs, accusation, j_actif, environnement);
                            end;
                    end;
                end
            else 
                begin
                    writeln('Que voulez-vous faire :');
                    writeln('   1 : Vous deplacer');
                    writeln('   2 : Formuler une hypothese'); 

                    repeat
                        write('Votre choix est : ');
                        readln(c);
                        if not((c >= 1) AND (c <= 2)) then
                            writeln('Ce choix est invalide.')
                        until ((c >= 1) AND (c <= 2));

                    case c of
                        1 : begin
                                lancerDes(lancer);
                                deplacement(plat, lancer, joueurs, j_actif);
                                if (estDansSalle(joueurs, plat, j_actif)) then
                                    begin
                                        ClrScr;
                                        affichageCartes(joueurs, j_actif);
                                        if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then
                                            faireHypothese(joueurs, hypo, plat, j_actif, environnement)
                                        else
                                            faireAccusation(etui, joueurs, accusation, j_actif, environnement);
                                    end;
                            end;
                        2 : begin
                                affichageCartes(joueurs, j_actif);
                                faireHypothese(joueurs, hypo, plat, j_actif, environnement);
                            end;
                    end;
                end;
        end
    else
        begin
            lancerDes(lancer);
            deplacement(plat, lancer, joueurs, j_actif);
            if (estDansSalle(joueurs, plat, j_actif)) then
                begin
                    ClrScr;
                    affichageCartes(joueurs, j_actif);
                    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then
                        faireHypothese(joueurs, hypo, plat, j_actif, environnement)
                    else
                        faireAccusation(etui, joueurs, accusation, j_actif, environnement);
                end;
        end;
end;



procedure deplacement(var plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);

var key : Char;
	move : Integer;
    co : Coords;
    bouge : Boolean;
    salle_act : Integer;

begin
    {Affichage du plateau}
    move := lancer;
    bouge := False;
    affichagePlateau(plat, joueurs);
    affichageDeplacement(move);


    if estDansSalle(joueurs, plat, j_actif) then
        begin
            case estDansLaSalle(plat, joueurs[j_actif].pos) of
                1 : 
                    begin
                        salle_act := 1;
                        affichageSortieSalle(1);
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 6;
                                        co[2] := 9;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                UP : 
                                    begin
                                        co[1] := 20;
                                        co[2] := 23;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := co[1];
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;
                                        bouge := True;
                                    end;
                            end;
                            until (bouge);
                    end;
                2 : 
                    begin
                        affichageSortieSalle(2);
                        salle_act := 2;
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 11;
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                UP :
                                    begin
                                        co[1] := 16;
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                LEFT : 
                                    begin
                                        co[1] := 9;
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                RIGHT :
                                    begin
                                        co[1] := 18;
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                3 : 
                    begin
                        affichageSortieSalle(3);
                        salle_act := 3;
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 21;
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                UP : 
                                    begin
                                        co[1] := 7;
                                        co[2] := 21;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := co[1];
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;
                                        bouge := True;
                                    end;
                            end;
                            until (bouge);
                    end;
                4 : 
                    begin
                        affichageSortieSalle(4);
                        salle_act := 4;
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 8;
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                RIGHT :
                                    begin
                                        co[1] := 10;
                                        co[2] := 14;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                5 : 
                    begin
                        affichageSortieSalle(5);
                        salle_act := 5;
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 24;
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                LEFT :
                                    begin
                                        co[1] := 19;
                                        co[2] := 11;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                6 : 
                    begin
                        affichageSortieSalle(6);
                        salle_act := 6;
                        repeat
                            key := readKey();
                            case key of 
                                UP : 
                                    begin
                                        co[1] := 22;
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                LEFT :
                                    begin
                                        co[1] := 18;
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                7 : 
                    begin
                        affichageSortieSalle(7);
                        salle_act := 7;
                        repeat
                            key := readKey();
                            case key of 
                                UP : 
                                    begin
                                        co[1] := 7;
                                        co[2] := 20;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                DOWN : 
                                    begin
                                        co[1] := 21;
                                        co[2] := 6;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := co[1];
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;
                                        bouge := True;
                                    end;
                            end;
                            until (bouge);
                    end;
                8 :
                    begin
                        affichageSortieSalle(8);
                        salle_act := 8;
                        repeat
                            key := readKey();
                            case key of 
                                UP :
                                    begin
                                        co[1] := 14;
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                LEFT : 
                                    begin
                                        co[1] := 13;
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                RIGHT :
                                    begin
                                        co[1] := 17;
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                9 : 
                    begin
                        affichageSortieSalle(9);
                        salle_act := 9;
                        repeat
                            key := readKey();
                            case key of 
                                UP : 
                                    begin
                                        co[1] := 20;
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                                DOWN : 
                                    begin
                                        co[1] := 6;
                                        co[2] := 8;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := co[1];
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;
                                        bouge := True;
                                    end;
                            end;
                            until (bouge);
                    end;
                10 : 
                    begin
                        affichageSortieSalle(10);
                        salle_act := 10;
                        repeat
                            key := readKey();
                            case key of 
                                DOWN : 
                                    begin
                                        co[1] := 14;
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                joueurs[j_actif].pos[1] := co[1];
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;
                                                bouge := True;
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
            end;
        end;


    {Déplace le pion en vérifiant les conditions de case d'arrivée, et réduit le nombre de déplacement restant jusqu'à que les déplacements restants soient à 0 ou que le joueur soit dans une salle}
    if not(estDansSalle(joueurs, plat, j_actif)) then
        begin
            repeat
	        	begin
                    affichageDeplacement(move);
		        	affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
		        	key := readKey();
		        	case key of
		        		UP : {Déplacement en haut}
                            begin
                                co[1] := joueurs[j_actif].pos[1];
                                co[2] := joueurs[j_actif].pos[2] - 1;
                                if ((joueurs[j_actif].pos[2] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] - 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then 
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] - 1;
                                        move := move - 1;
				        	        end;
                            end;
				        DOWN : {Déplacement en bas}
                            begin
                                co[1] := joueurs[j_actif].pos[1];
                                co[2] := joueurs[j_actif].pos[2] + 1;
                                if ((joueurs[j_actif].pos[2] + 1 <= 26) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] + 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then 
					                begin
					                	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] + 1;
                                        move := move - 1;
					                end;
                            end;
				        LEFT : {Déplacement à gauche}
                            begin
                                co[1] := joueurs[j_actif].pos[1] - 1;
                                co[2] := joueurs[j_actif].pos[2];
                                if ((joueurs[j_actif].pos[1] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1] - 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then 
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] - 1;
                                        move := move - 1;
                                    end;
				        	end;
				        RIGHT : {Déplacement à droite}
                            begin
                                co[1] := joueurs[j_actif].pos[1] + 1;
                                co[2] := joueurs[j_actif].pos[2];
                                if ((joueurs[j_actif].pos[1] + 1 <= 25) AND (plat.grille[joueurs[j_actif].pos[1] + 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then 
					                begin
					        	        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] + 1;
                                        move := move - 1;
                                    end;
					        end;
                    end;
		        end;
		        until ((move = 0) OR estDansSalle(joueurs, plat, j_actif));


            {Ajout d'un joueur dans la salle si il rentre dans une salle}
            if estDansSalle(joueurs, plat, j_actif) then
                placementSalle(joueurs, plat, j_actif);
        end;
        
    
    placementSalle(joueurs, plat, j_actif);
    affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
    affichageDeplacement(move);
    Delay(1000);
    ClrScr;
end;



procedure lancerDes(var lancer : Integer);

var de1, de2 : Integer;
    continue : Char;

begin
    {Lance les 2 dés de manière aléatoire}
    Randomize;

    de1 := random(5) + 1;
    de2 := random(5) + 1;

    lancer := de1 + de2;

    {Affiche la valeur des deux dés ainsi que le nombre de déplacements total}
	writeln('Le premier de a pour valeur ', de1, ' et le second ', de2, '. Le nombre de deplacement total est donc de ', lancer, '.');

    writeln('(Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = #32);
end;



procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);

var g1, g2, reveal, carte : ListeCartes;
    perso, arme, temp : set of ListeCartes;
    i, j, k, l, nb : Integer;
    montrer : Boolean;
    commun : Array of ListeCartes;

begin 
    {Déclaration et remplissage des ensembles personnage et arme propre à l'envrionnement}
    perso := [];
    arme := [];
    if environnement = Manoir then
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
        end
    else
        begin
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
        end;


    {Enregistre les éléments de l'hypothèse}
    writeln('Vous allez formuler une hypothese !');

    repeat
        write('Selon vous, qui pourrait-etre l''assassin ? ');
        readln(g1);
        if not(g1 in perso) then
            writeln('La carte ne correspond pas a un personnage.')
        until (g1 in perso);
    hypo[1] := g1;

    repeat
        write('Selon vous, quelle pourrait-etre l''arme du crime ? ');
        readln(g2);
        if not(g2 in arme) then
            writeln('La carte ne correspond pas a une arme')
        until (g2 in arme);
    hypo[2] := g2;

    hypo[3] := plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom;


    {Affiche l'hypothèse en entière}
    writeln('Votre hypothese est donc la suivante : ', hypo[1], ' ', hypo[2], ' ', hypo[3]);
    Delay(5000);


    {Demande aux joueurs suivants si il possède une des cartes de l'hypothèse formulée}
    ClrScr;
    montrer := False;
    j := j_actif;
    i := 1;


    {Répète la demande au joueur en stockant les cartes en commun entre le joueur j et l'hypothèse formulée jusqu'à ce qu'une carte coincide ou que tout les joueurs aient été interrogés}
    repeat 
        if (j + 1 > length(joueurs)) then
            j := (j + 1) mod length(joueurs)
        else
            j := j + 1;


        temp := [];
        for k := 1 to 3 do
            begin
                if (hypo[k] in joueurs[j].cartes) then
                    begin
                        Include(temp, hypo[k]);
                    end;
            end;


        if (temp <> []) then
            begin
                nb := 0;
                for carte in temp do
                    begin
                        nb := nb + 1;
                    end;
                
                SetLength(commun, nb);
                l := 1;
                for carte in temp do
                    begin
                        commun[l] := carte;
                        l := l + 1;
                    end;

                affichageMontrerCartes(commun, joueurs, j, j_actif, reveal);
                montrer := True;
                SetLength(commun, 0);
            end
        else
            begin
                colorPerso(joueurs, j);
                write(joueurs[j].perso);
                TextColor(15);
                writeln(' n''as aucune des cartes de votre hypothese.');
                Delay(1000);
            end;

        i := i + 1;

        until (montrer OR (i = length(joueurs)));


    {Affiche au j_actif qu'aucun des joueurs ne possède les cartes de l'hypothèse si c'est le cas}
    if not(montrer) then
        writeln('Aucun des enqueteurs ne possede une carte de votre hypothese !');    
end;



procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);

var guess : Array [0..2] of ListeCartes;
    g1, g2, g3, carte : ListeCartes;
    perso, arme, lieu : set of ListeCartes;

begin 
    {Déclaration et remplissage des ensembles personnage et arme propre à l'envrionnement}
    perso := [];
    arme := [];
    lieu := [];
    if environnement = Manoir then
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
            for carte := Cuisine to Studio do
                Include(lieu, carte);
        end
    else
        begin  
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
            for carte := Cafete to BU do
                Include(lieu, carte);
        end;


    {Enregistre les éléments de l'accusation}
    writeln('Vous allez formuler une accusation !');

    repeat
        write('Selon vous, qui est l''assassin ? ');
        readln(g1);
        if not(g1 in perso) then
            writeln('La carte ne correspond pas a un personnage.')
        until (g1 in perso);
    guess[0] := g1;

    repeat
        write('Selon vous, quelle est l''arme du crime ? ');
        readln(g2);
        if not(g2 in arme) then
            writeln('La carte ne correspond pas a une arme')
        until (g2 in arme);
    guess[1] := g2;

    repeat
        write('Selon vous, dans quelle salle l''assassinat a-t-il eu lieu ? ');
        readln(g3);
        if not(g3 in lieu) then
            writeln('La carte ne correspond pas a un lieu')
        until (g3 in lieu);
    guess[2] := g3;


    {Vérifie que les ensembles de l'accusation et de l'étui coincident, sinon le joueur du tour meurt}
    if ((etui[0] = guess[0]) AND (etui[1] = guess[1]) AND (etui[2] = guess[2])) then
        accusation := True
    else
        begin
            joueurs[j_actif].enVie := False;
            ClrScr;
            write('Malheuresement, l''accusation de ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15);
            writeln(' n''etait pas la bonne. Il ne fait donc plus partie de l''enquete.');
        end;
end;



procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);

begin
    {Si l'accusation est vérifiée alors affiche le gagnant, sinon annonce affiche la défaite de tous}
    if accusation then
        begin
            if (j_actif - 1 = 0) then
                j_actif := length(joueurs)
            else
                j_actif := j_actif - 1;
    
            writeln('La partie est terminee ! Un enqueteur a trouve le meurtrier, l''arme du crime et le lieu de l''assassinnat.');
            write('Et cet en enqueteur est ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15); 
            writeln(' !');
            write('Voici les elements du meurtre : ', etui[0], ' ', etui[1], ' ', etui[2], '.');
        end
    else
        begin
            writeln('Aucun des enqueteurs n''est parvenu a resoudre ce meurtre. La partie est finie.');
            writeln('Voici les elements du meurtre : ', etui[0], ' ', etui[1], ' ', etui[2], '.');
        end;
end;



function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;

var i : Integer;

begin
    {Renvoie True si la case est libre, False sinon}
    caseEstLibre := True;
    for i := 1 to length(joueurs) do
        begin
            if ((co[1] = joueurs[i].pos[1]) AND (co[2] = joueurs[i].pos[2])) then
                caseEstLibre := False;
        end;
end;



procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);

var co : Coords;
    i : Integer;

begin
    i := 1;


	if estDansSalle(joueurs, plat, j_actif) then
        begin
            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
			case estDansLaSalle(plat, joueurs[j_actif].pos) of
                1 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 3;
                                        co[2] := 5;
                                    end;
                                2 : begin
                                        co[1] := 4;
                                        co[2] := 5;
                                    end;
                                3 : begin
                                        co[1] := 5;
                                        co[2] := 5;
                                    end;
                                4 : begin
                                        co[1] := 3;
                                        co[2] := 6;
                                    end;
                                5 : begin
                                        co[1] := 4;
                                        co[2] := 6;
                                    end;
                                6 : begin
                                        co[1] := 5;
                                        co[2] := 6;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;                                
                2 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 12;
                                        co[2] := 6;
                                    end;
                                2 : begin
                                        co[1] := 13;
                                        co[2] := 6;
                                    end;
                                3 : begin
                                        co[1] := 14;
                                        co[2] := 6;
                                    end;
                                4 : begin
                                        co[1] := 15;
                                        co[2] := 6;
                                    end;
                                5 : begin
                                        co[1] := 13;
                                        co[2] := 7;
                                    end;
                                6 : begin
                                        co[1] := 14;
                                        co[2] := 7;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                3 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 4;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 4;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 4;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 5;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 5;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 5;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                4 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 4;
                                        co[2] := 14;
                                    end;
                                2 : begin
                                        co[1] := 5;
                                        co[2] := 14;
                                    end;
                                3 : begin
                                        co[1] := 6;
                                        co[2] := 14;
                                    end;
                                4 : begin
                                        co[1] := 7;
                                        co[2] := 14;
                                    end;
                                5 : begin
                                        co[1] := 5;
                                        co[2] := 15;
                                    end;
                                6 : begin
                                        co[1] := 6;
                                        co[2] := 15;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                5 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 12;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 12;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 12;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 13;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 13;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 13;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                6 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 17;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 17;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 17;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 18;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 18;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 18;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                7 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 3;
                                        co[2] := 24;
                                    end;
                                2 : begin
                                        co[1] := 4;
                                        co[2] := 24;
                                    end;
                                3 : begin
                                        co[1] := 5;
                                        co[2] := 24;
                                    end;
                                4 : begin
                                        co[1] := 6;
                                        co[2] := 24;
                                    end;
                                5 : begin
                                        co[1] := 4;
                                        co[2] := 25;
                                    end;
                                6 : begin
                                        co[1] := 5;
                                        co[2] := 25;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                8 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 13;
                                        co[2] := 22;
                                    end;
                                2 : begin
                                        co[1] := 14;
                                        co[2] := 22;
                                    end;
                                3 : begin
                                        co[1] := 13;
                                        co[2] := 23;
                                    end;
                                4 : begin
                                        co[1] := 14;
                                        co[2] := 23;
                                    end;
                                5 : begin
                                        co[1] := 13;
                                        co[2] := 24;
                                    end;
                                6 : begin
                                        co[1] := 14;
                                        co[2] := 24;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                9 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 21;
                                        co[2] := 25;
                                    end;
                                2 : begin
                                        co[1] := 22;
                                        co[2] := 25;
                                    end;
                                3 : begin
                                        co[1] := 23;
                                        co[2] := 25;
                                    end;
                                4 : begin
                                        co[1] := 24;
                                        co[2] := 25;
                                    end;
                                5 : begin
                                        co[1] := 22;
                                        co[2] := 26;
                                    end;
                                6 : begin
                                        co[1] := 23;
                                        co[2] := 26;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                10 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 13;
                                        co[2] := 15;
                                    end;
                                2 : begin
                                        co[1] := 14;
                                        co[2] := 15;
                                    end;
                                3 : begin
                                        co[1] := 15;
                                        co[2] := 15;
                                    end;
                                4 : begin
                                        co[1] := 13;
                                        co[2] := 16;
                                    end;
                                5 : begin
                                        co[1] := 14;
                                        co[2] := 16;
                                    end;
                                6 : begin
                                        co[1] := 15;
                                        co[2] := 16;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
			end;
		end;
end;



{procedure quitterSauvegarder(joueurs : ListeJoueurs; plat : Plateau; var etui : Array of ListeCartes; var sauvegarde : File);}

end.