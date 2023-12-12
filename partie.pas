Unit partie;


Interface


uses unite, Crt, affichage, sysutils;


procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro; var j_actif : Integer);
procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
procedure lancerDes(var lancer : Integer);
procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);
procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);
procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro; plat : Plateau);
procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);
procedure quitterSauvegarder(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; j_actif : Integer; environnement : Enviro);
function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;
function joueursEnVie(joueurs : ListeJoueurs) : Integer;
function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;
function sortieSallePossible(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;



Implementation


procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro; var j_actif : Integer);
{Procédure principale du programme un fois qu'une partie est lancée
Elle va lancer les tours un par un, et ce pour pour chaque joueur
Le programme s'arrête lorsque l'on quitte manuellement ou lorsque la partie se termine}

var accusation : Boolean;
    key : Char;

begin
    ClrScr;  // Le terminal est nettoyé
    accusation := False;  // Boolean qui vaut False le temps que l'enquête n'as pas ete résolue


    repeat  // Boucle lançant les tours pour chaque joueur jusqu'à ce que l'on quitte ou qu'il n'y ait plus assez de joueurs en vie ou que les éléments du meurtre aient été trouvés
        if (joueurs[j_actif].enVie) then
            tour(plat, etui, joueurs, accusation, j_actif, environnement);  // Lance le tour du joueur 'actif' si il est en vie
            

        if ((joueursEnVie(joueurs) < 1) OR (accusation)) then  // Si la partie est finie, le procédure finPartie est appelé
            begin
                ClrScr;  // Le terminal est nettoyé
                finPartie(joueurs, accusation, j_actif, etui);  
                writeln('(Appuyer sur ''espace'')');
                repeat 
                    key := readKey();
                    until (key = SPACE);
            end
        else  // Sinon le joueur 'actif' est maintenant le joueur suivant
            if (joueurs[j_actif].enVie) then  // Verification du lancement du tour du joueur 'actif' pour demander de quitter la partie
                    begin
                        writeln('Appuyer sur ''Q'' pour quitter ou sur n''importe quelle autre touche pour continuer.');  // Si la touche 'Q' est pressée, la partie s'arrête, sinon le tour d'après est lancé
                        key := readKey();
                    end;

            begin
                if (j_actif = length(joueurs)) then  // Si le dernier joueur à avoir joué est le dernier de la liste de joueurs, le joueur 'actif' devient le permier de la liste
                    j_actif := 1  
                else  // Sinon, c'est le joueur suivant qui devient le joueur 'actif'
                    j_actif := j_actif + 1;  
            end;


        if (key = QUIT) then
            quitterSauvegarder(joueurs, etui, j_actif, environnement);  // Quitte la partie si 'Q' est pressée

        until ((key = QUIT) OR (joueursEnVie(joueurs) < 1) OR (accusation));  // La partie continue le temps que 'Q' n'est pas pressée, qu'il y a au moins un joueur en vie et que l'accusation n'ait pas été découverte

    ClrScr;
end;



procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
{Procedure centrale qui présente les différentes actions possibles au joueur 'actif' et qui appelle les procédures selon le choix du joueur}

var c, lancer : Integer;
    hypo : Array [1..3] of ListeCartes;
    continue : Char;

begin
    ClrScr;  // Le terminal est nettoyé

    write('C''est a ');  // Indique le joueur qui va jouer
    colorPerso(joueurs, j_actif);  // Appel de la procédure pour la coloration de l'encre pour l'écriture du nom du personnage
    write(joueurs[j_actif].perso);
    TextColor(15);  // Rétablie la couleur de l'encre d'origine : blanc
    writeln(' de jouer ! (Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' soit prêt à jouer en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);   


    affichageCartes(joueurs, j_actif);  // Appel de la procédure permettant d'afficher les cartes du joueur 'actif'


    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Affiche la salle dans laquelle le joueur 'actif' se trouve, si il est dans une salle
        writeln('Vous etes actuellement dans la salle : ', plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom, '.');
    writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de ses cartes et de la salle dans laquelle il se trouve en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);
    
    case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
        0 : // Le joueur 'actif' n'est dans aucune salle au début du tour
            begin  
                lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                    begin
                        if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                            faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                        else  // Sinon
                            faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                    end;
            end;
        1..9 :  // Le joueur 'actif' est dans une salle différente de la salle d'accusation au début du tour
            begin
                if sortieSallePossible(joueurs, plat, j_actif) then  // Vérifie si le joueur 'actif' peut sortir de la salle dans laquelle il se trouve
                    begin
                        {Propose au joueur 'actif' les actions possibles}
                        writeln('Que voulez-vous faire :');
                        writeln('   1 : Vous deplacer');
                        writeln('   2 : Formuler une hypothese'); 

                        {Lecture du choix d'action du joueur 'actif' et vérification que l'action soit possible}
                        repeat
                            write('Votre choix est : ');
                            readln(c);
                            if not((c >= 1) AND (c <= 2)) then
                                writeln('Ce choix est invalide.')
                            until ((c >= 1) AND (c <= 2));

                        {Lance les action en fonction du choix du joueur 'actif'}
                        case c of
                            1 : begin  // Choix : déplacement
                                    lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                                    deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                                    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                                        begin
                                            if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                                                faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                            else  // Sinon
                                                faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                        end;
                                end;
                            2 : begin  // Choix : Formulation d'hypothèse
                                    faireHypothese(joueurs, hypo, plat, j_actif, environnement);  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                end;
                        end;
                    end
                else  // Si le joueur 'actif' ne peut pas sortir de la salle
                    begin
                        writeln('Vous ne pouvez pas sortir de cette salle actuellement. Vous allez donc formuler une hypothèse. (Appuyer sur ''espace'')');
                        repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de la situation en appuyant sur 'espace'
                            continue := readKey();
                            until (continue = SPACE);
                        faireHypothese(joueurs, hypo, plat, j_actif, environnement);  // Appel de la procedure faireHypothese pour formuler une hypothèse
                    end;
            end;
        10 :  // Le joueur 'actif' est dans la salle d'accusation au début du tour
            begin
                if sortieSallePossible(joueurs, plat, j_actif) then  // Vérifie si le joueur 'actif' peut sortir de la salle dans laquelle il se trouve
                    begin
                        {Propose au joueur 'actif' les actions possibles}
                        writeln('Que voulez-vous faire :');
                        writeln('   1 : Vous deplacer');
                        writeln('   2 : Formuler une accusation'); 

                        {Lecture du choix d'action du joueur 'actif' et vérification que l'action soit possible}
                        repeat
                            write('Votre choix est : ');
                            readln(c);
                            if not((c >= 1) AND (c <= 2)) then
                                writeln('Ce choix est invalide.')
                            until ((c >= 1) AND (c <= 2));

                        {Lance les action en fonction du choix du joueur 'actif'}
                        case c of
                            1 : begin  // Choix : déplacement
                                    lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                                    deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                                    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                                        begin
                                            if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                                                faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                            else  // Sinon
                                                faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                        end;
                                end;
                            2 : begin  // Choix : Formulation d'une accusation
                                    faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                end;
                        end;
                    end
                else  // Si le joueur 'actif' ne peut pas sortir de la salle
                    begin
                        writeln('Vous ne pouvez pas sortir de cette salle actuellement. Vous allez donc formuler une accusation. (Appuyer sur ''espace'')');
                        repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de la situation en appuyant sur 'espace'
                            continue := readKey();
                            until (continue = SPACE);
                        faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                    end;
            end;
    end;
end;



    



procedure lancerDes(var lancer : Integer);
{Procedure permettant de jeter virtuellement deux dés, et la valeur de la somme de ces deux derniers correspond au nombre de déplacement disponible}

var de1, de2 : Integer;
    continue : Char;

begin
    Randomize;  // Appel de la procédure Randomize afin de pouvoir uiliser la fonction random

    de1 := random(5) + 1;  // de1 prend une valeur aléatoire tirée entre 1 et 6
    de2 := random(5) + 1;  // de2 prend une valeur aléatoire tirée entre 1 et 6

    lancer := de1 + de2;  // lancer est donc la somme des deux dés

	writeln('Le premier de a pour valeur ', de1, ' et le second ', de2, '. Le nombre de deplacement total est donc de ', lancer, '.'); // Affiche la valeur des deux dés ainsi que le nombre de déplacements total
    writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance du nombre de déplacement qu'il possède en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);
end;



procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
{Procedure permettant au joueur 'actif' de se déplacer sur le plateau de jeu}

var key : Char;
	move : Integer;
    co : Coords;
    bouge : Boolean;
    salle_act : Integer;

begin
    {Affichage du plateau}
    move := lancer;  // move est la variable qui compte le nombre de déplacements restants
    bouge := False;  // Boolean permettant de savoir si le joueur 'actif' est sorti de la salle dans laquelle il se trouve au début du tour, si il se trouve dans l'une d'elle
    affichagePlateau(plat, joueurs);  // Appel de la procedure affichant le plateau de jeu
    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants


    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
        begin
            case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
                1 :  // Le joueur 'actif' se trouve dans la salle 1
                    begin
                        affichageSortieSalle(1);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 1;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 6;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 9;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 20;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 23;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                2 :  // Le joueur 'actif' se trouve dans la salle 2
                    begin
                        affichageSortieSalle(2);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 2;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of   // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 11;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 16;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 9;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 18;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                3 :  // Le joueur 'actif' se trouve dans la salle 3
                    begin
                        affichageSortieSalle(3);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 3;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of   // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 21;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 7;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 21;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                4 :  // Le joueur 'actif' se trouve dans la salle 4
                    begin
                        affichageSortieSalle(4);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 4;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 8;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 10;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 14;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                5 :  // Le joueur 'actif' se trouve dans la salle 5
                    begin
                        affichageSortieSalle(5);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 5;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 24;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 19;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 11;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                6 :  // Le joueur 'actif' se trouve dans la salle 6
                    begin
                        affichageSortieSalle(6);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 6;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 22;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 18;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                7 :  // Le joueur 'actif' se trouve dans la salle 7
                    begin
                        affichageSortieSalle(7);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 7;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 7;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 20;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 21;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 6;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                8 :  // Le joueur 'actif' se trouve dans la salle 8
                    begin 
                        affichageSortieSalle(8);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 8;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 14;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 13;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 17;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                9 :  // Le joueur 'actif' se trouve dans la salle 9
                    begin
                        affichageSortieSalle(9);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 9;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 20;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle 
                                    begin
                                        co[1] := 6;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 8;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
                10 :  // Le joueur 'actif' se trouve dans la salle 10
                    begin
                        affichageSortieSalle(10);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 10;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 14;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                        affichagePlateau(plat, joueurs);
                    end;
            end;
        end;


    {Déplace le pion en vérifiant les conditions de case d'arrivée, et réduit le nombre de déplacement restant jusqu'à que les déplacements restants soient à 0 ou que le joueur soit dans une salle}
    if (estDansLaSalle(plat, joueurs[j_actif].pos) = 0) then  // Vérification de la présence du joueur 'actif' dans aucune salle
        begin
            repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas dans une salle ou qu'il lui reste des déplacements
	        	begin
                    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants
		        	affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Affiche la position du pion du joueur 'actif' sur le plateau de jeu
		        	key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
		        	case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
		        		UP :  // Déplacement en haut
                            begin
                                co[1] := joueurs[j_actif].pos[1];    // Coordonnées de la case située au dessus du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2] - 1;
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[2] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] - 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] - 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
				        	        end;
                            end;
				        DOWN : // Déplacement en bas
                            begin
                                co[1] := joueurs[j_actif].pos[1];  // Coordonnées de la case située au dessous du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2] + 1;
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[2] + 1 <= 26) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] + 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
					                begin
					                	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] + 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
					                end;
                            end;
				        LEFT : // Déplacement à gauche
                            begin
                                co[1] := joueurs[j_actif].pos[1] - 1;  // Coordonnées de la case située à gauche du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2];
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[1] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1] - 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] - 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                    end;
				        	end;
				        RIGHT : // Déplacement à droite
                            begin
                                co[1] := joueurs[j_actif].pos[1] + 1;  // Coordonnées de la case située à droite du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2];
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[1] + 1 <= 25) AND (plat.grille[joueurs[j_actif].pos[1] + 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
					                begin
					        	        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] + 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                    end;
					        end;
                    end;
		        end;
		        until ((move = 0) OR (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0));
        end;
        
    
    placementSalle(joueurs, plat, j_actif);  // Appel de la procédure pour placer le joueur dans la salle dans laquelle il se trouve, si c'est le cas
    affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Affiche la position du pion du joueur 'actif' sur le plateau de jeu
    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants
    Delay(1000);  // Le programme attend environ 1000 ms avant de continuer 
    ClrScr;  // Le terminal est nettoyé
end;



procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);
{Procedure qui place correctement les joueurs dans les salles}

var co : Coords;
    i : Integer;

begin
    i := 1;  // Initialisation de la variable définissant la position d'arrivee du joueur 'actif'


	if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Verification de la présence le joueur 'actif' dans une salle avant de le placer
        begin
            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Appel de la procédure pour enlever le pion du joueur 'actif' du plateau
			case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
                1 :  // Le joueur 'actif' se trouve dans la salle 1
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 3;  // Coordonnees de la case 1
                                        co[2] := 5;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 4;  // Coordonnees de la case 2
                                        co[2] := 5;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 5;  // Coordonnees de la case 3
                                        co[2] := 5;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 3;  // Coordonnees de la case 4
                                        co[2] := 6;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 4;  // Coordonnees de la case 5
                                        co[2] := 6;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 5;  // Coordonnees de la case 6
                                        co[2] := 6;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;                                
                2 :  // Le joueur 'actif' se trouve dans la salle 2
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 12;  // Coordonnees de la case 1
                                        co[2] := 6;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 13;  // Coordonnees de la case 2
                                        co[2] := 6;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 14;  // Coordonnees de la case 3
                                        co[2] := 6;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 15;  // Coordonnees de la case 4
                                        co[2] := 6;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 13;  // Coordonnees de la case 5
                                        co[2] := 7;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 14;  // Coordonnees de la case 6
                                        co[2] := 7;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                3 :  // Le joueur 'actif' se trouve dans la salle 3
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 22;  // Coordonnees de la case 1
                                        co[2] := 4;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 23;  // Coordonnees de la case 2
                                        co[2] := 4;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 24;  // Coordonnees de la case 3
                                        co[2] := 4;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 22;  // Coordonnees de la case 4
                                        co[2] := 5;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 23;  // Coordonnees de la case 5
                                        co[2] := 5;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 24;  // Coordonnees de la case 6
                                        co[2] := 5;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                4 :  // Le joueur 'actif' se trouve dans la salle 4
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 4;  // Coordonnees de la case 1
                                        co[2] := 14;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 5;  // Coordonnees de la case 2
                                        co[2] := 14;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 6;  // Coordonnees de la case 3
                                        co[2] := 14;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 7;  // Coordonnees de la case 4
                                        co[2] := 14;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 5;  // Coordonnees de la case 5
                                        co[2] := 15;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 6;  // Coordonnees de la case 6
                                        co[2] := 15;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                5 :  // Le joueur 'actif' se trouve dans la salle 5
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 22;  // Coordonnees de la case 1
                                        co[2] := 12;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 23;  // Coordonnees de la case 2
                                        co[2] := 12;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 24;  // Coordonnees de la case 3
                                        co[2] := 12;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 22;  // Coordonnees de la case 4
                                        co[2] := 13;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 23;  // Coordonnees de la case 5
                                        co[2] := 13;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 24;  // Coordonnees de la case 6
                                        co[2] := 13;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                6 :  // Le joueur 'actif' se trouve dans la salle 6
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 22;  // Coordonnees de la case 1
                                        co[2] := 17;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 23;  // Coordonnees de la case 2
                                        co[2] := 17;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 24;  // Coordonnees de la case 3
                                        co[2] := 17;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 22;  // Coordonnees de la case 4
                                        co[2] := 18;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 23;  // Coordonnees de la case 5
                                        co[2] := 18;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 24;  // Coordonnees de la case 6
                                        co[2] := 18;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                7 :  // Le joueur 'actif' se trouve dans la salle 7
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 3;  // Coordonnees de la case 1
                                        co[2] := 24;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 4;  // Coordonnees de la case 2
                                        co[2] := 24;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 5;  // Coordonnees de la case 3
                                        co[2] := 24;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 6;  // Coordonnees de la case 4
                                        co[2] := 24;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 4;  // Coordonnees de la case 5
                                        co[2] := 25;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 5;  // Coordonnees de la case 6
                                        co[2] := 25;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                8 :  // Le joueur 'actif' se trouve dans la salle 8
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 13;  // Coordonnees de la case 1
                                        co[2] := 22;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 14;  // Coordonnees de la case 2
                                        co[2] := 22;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 13;  // Coordonnees de la case 3
                                        co[2] := 23;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 14;  // Coordonnees de la case 4
                                        co[2] := 23;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 13;  // Coordonnees de la case 5
                                        co[2] := 24;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 14;  // Coordonnees de la case 6
                                        co[2] := 24;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                9 :  // Le joueur 'actif' se trouve dans la salle 9
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 21;  // Coordonnees de la case 1
                                        co[2] := 25;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 22;  // Coordonnees de la case 2
                                        co[2] := 25;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 23;  // Coordonnees de la case 3
                                        co[2] := 25;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 24;  // Coordonnees de la case 4
                                        co[2] := 25;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 22;  // Coordonnees de la case 5
                                        co[2] := 26;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 23;  // Coordonnees de la case 6
                                        co[2] := 26;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                10 :  // Le joueur 'actif' se trouve dans la salle 10
                    begin
                        repeat  // Boucle se repetant tant que le joueur 'actif' n'est pas sur une nouvelle case
                            case i of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la variable i
                                1 : begin  // i vaut 1
                                        co[1] := 13;  // Coordonnees de la case 1
                                        co[2] := 15;
                                    end;
                                2 : begin  // i vaut 2
                                        co[1] := 14;  // Coordonnees de la case 2
                                        co[2] := 15;
                                    end;
                                3 : begin  // i vaut 3
                                        co[1] := 15;  // Coordonnees de la case 3
                                        co[2] := 15;
                                    end;
                                4 : begin  // i vaut 4
                                        co[1] := 13;  // Coordonnees de la case 4
                                        co[2] := 16;
                                    end;
                                5 : begin  // i vaut 5
                                        co[1] := 14;  // Coordonnees de la case 5
                                        co[2] := 16;
                                    end;
                                6 : begin  // i vaut 6
                                        co[1] := 15;  // Coordonnees de la case 6
                                        co[2] := 16;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then  // Verification de l'absence de joueur sur la case i
                                begin
                                    joueurs[j_actif].pos[1] := co[1];  // Mise a jour de la position du joueur 'actif' si la case i est libre
						            joueurs[j_actif].pos[2] := co[2];
                                end
                            else
                                i := i + 1;  // Sinon on passe a la case suivante

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
			end;
		end;
end;



procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);
{Procedure permettant au joueur 'actif' de formuler une hypothese}

var g1, g2, reveal, carte : ListeCartes;
    perso, arme, temp : set of ListeCartes;
    i, j, k, l, nb : Integer;
    montrer : Boolean;
    commun : Array of ListeCartes;
    carteStr : String;
    key : Char;

begin 
    perso := [];  // Initialisation de l'ensemble des personnages 
    arme := [];  // Initialisation de l'ensemble des armes
    if environnement = Manoir then  // Remplissage des ensembles perso et arme dans le cas de l'environnement Manoir
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
        end
    else  // Remplissage des ensembles perso et arme dans le cas de l'environnement INSA
        begin
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
        end;


    ClrScr;
    affichageCartes(joueurs, j_actif);  // Appel de la procédure permettant d'afficher les cartes du joueur 'actif'


    writeln('Vous allez formuler une hypothese !');

    repeat  // Boucle se repetant tant que le joueur 'actif' n'a pas rentré une carte valide
        write('Selon vous, qui pourrait-etre l''assassin ? Voici les choix possibles : ');
        for carte in perso do write(ListeCartesToStr(carte), ', ');  // Affchage de toutes les cartes dans l'ensemble perso
        writeln();
        readln(carteStr);
        if StrCorrect(carteStr) then  // Verification de la bonne saisie de la carte
            begin
                g1 := StrToListeCartes(carteStr);
                if not(g1 in perso) then  // Verification de la presence de la carte dans l'ensemble perso
                    begin
                        writeln('La carte ne correspond pas a un personnage.');
                    end;
            end
        else
            begin
                writeln('La saisie est incorrecte.');
            end;
        until ((g1 in perso) AND StrCorrect(carteStr));
    hypo[1] := g1;  // La premiere valeur du tableau hypo est le personnage que le joueur 'actif' soupçonne d'etre l'assassin


    repeat  // Boucle se repetant tant que le joueur 'actif' n'a pas rentré une carte valide
        write('Selon vous, quelle pourrait-etre l''arme du crime ? Voici les choix possibles : ');
        for carte in arme do write(ListeCartesToStr(carte), ', ');  // Affchage de toutes les cartes dans l'ensemble arme
        writeln();
        readln(carteStr);
        if StrCorrect(carteStr) then  // Verification de la bonne saisie de la carte
            begin
                g2 := StrToListeCartes(carteStr);
                if not(g2 in arme) then  // Verification de la presence de la carte dans l'ensemble arme
                    begin
                        writeln('La carte ne correspond pas a une arme.');
                    end;
            end
        else
            begin
                writeln('La saisie est incorrecte.');
            end;
        until ((g2 in arme) AND StrCorrect(carteStr));
    hypo[2] := g2;  // La deuxieme valeur du tableau hypo est l'arme que le joueur 'actif' soupçonne d'etre l'arme du crime


    hypo[3] := plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom;  // La troisieme valeur du tableau hypo est le lieu que le joueur 'actif' soupçonne d'etre le lieu du crime


    i := 0;
    repeat  // Boucle se repetant tant que le joueur suspecté par le joueur 'actif' n'ai pas ete deplace dans la meme salle que ce dernier
        Inc(i);
        if (hypo[1] = joueurs[i].perso) then  // Verification de la correspondance entre le joueur i et le joueur suspecte
            begin
                affiche(' ', joueurs[i].pos[1], joueurs[i].pos[2]);  // Appel de la procédure pour enlever le pion du joueur i du plateau
                case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
                    1 : begin  // Le joueur 'actif' se trouve dans la salle 1
                            joueurs[i].pos[1] := 6;  // Coordonnees de la salle 1
                            joueurs[i].pos[2] := 8;
                        end;
                    2 : begin  // Le joueur 'actif' se trouve dans la salle 2
                            joueurs[i].pos[1] := 11;  // Coordonnees de la salle 2
                            joueurs[i].pos[2] := 9;
                        end;
                    3 : begin  // Le joueur 'actif' se trouve dans la salle 3
                            joueurs[i].pos[1] := 21;  // Coordonnees de la salle 3
                            joueurs[i].pos[2] := 6;
                        end;
                    4 : begin  // Le joueur 'actif' se trouve dans la salle 4
                            joueurs[i].pos[1] := 9;  // Coordonnees de la salle 4
                            joueurs[i].pos[2] := 14;
                        end;
                    5 : begin  // Le joueur 'actif' se trouve dans la salle 5
                            joueurs[i].pos[1] := 24;  // Coordonnees de la salle 5
                            joueurs[i].pos[2] := 14;
                        end;
                    6 : begin  // Le joueur 'actif' se trouve dans la salle 6
                            joueurs[i].pos[1] := 22;  // Coordonnees de la salle 
                            joueurs[i].pos[2] := 16;
                        end;
                    7 : begin  // Le joueur 'actif' se trouve dans la salle 7
                            joueurs[i].pos[1] := 7;  // Coordonnees de la salle 7
                            joueurs[i].pos[2] := 21;
                        end;
                    8 : begin  // Le joueur 'actif' se trouve dans la salle 8
                            joueurs[i].pos[1] := 13;  // Coordonnees de la salle 8
                            joueurs[i].pos[2] := 20;
                        end;
                    9 : begin  // Le joueur 'actif' se trouve dans la salle 9
                            joueurs[i].pos[1] := 20;  // Coordonnees de la salle 9
                            joueurs[i].pos[2] := 23;
                        end;
                end;
            end;
        until ((i = length(joueurs) + 1) OR (hypo[1] = joueurs[i-1].perso));
    

    writeln();
    writeln('Votre hypothese est donc la suivante : ', hypo[1], ' ', hypo[2], ' ', hypo[3], '. (Appuyer sur ''espace'')');  // Affiche l'hypothèse en entière
    repeat
        key := readKey();
        until (key = SPACE);

    placementSalle(joueurs, plat, i);  // Appel de la procedure Placement salle pour placer correctement le joueur soupçonne dans la meme salle que le joueur 'actif'
    ClrScr;
    montrer := False;
    j := j_actif;
    i := 1;


    repeat   // Boucle se repetant jusqu'a ce qu'un joueur ait montre une de ses cartes au joueur 'actif' ou qu'aucun des joueurs de la partie n'ait de carte de l'hypothese
        if (j + 1 > length(joueurs)) then  // Verification du non depassement de la liste de joueur
            j := (j + 1) mod length(joueurs)  // Si c'est le cas, le joueur 'actif' interroge le premier joueur
        else  // Sinon il interroge le joueur suivant
            j := j + 1;

        temp := [];  // Initialisation de l'ensemble stockant les cartes en commun entre le joueur j et les cartes de l'hypothese
        for k := 1 to 3 do  // Boucle qui parcours toutes les cartes de l'hypothese
            begin
                if (hypo[k] in joueurs[j].cartes) then  // Verification de la presence de la carte hypo[k] dans les cartes du joueur j
                    begin
                        Include(temp, hypo[k]);  // Si c'est le cas, ajout de la carte hypo[k] dans l'ensemble temp
                    end;
            end;

        if (temp <> []) then  // Verification de la presence de cartes dans l'ensemble temp
            begin
                nb := 0;  // Initialisation de la variable stockant le nombre de carte dans l'ensemble temp
                for carte in temp do  // Boucle qui parcours toutes les cartes de l'hypothese et incremente la variable nb a chaque carte 
                    begin
                        Inc(nb);
                    end;
                
                SetLength(commun, nb);  // Initialisation de la longueur du tableau commun 
                l := 1;
                for carte in temp do  // Boucle qui parcours toutes les cartes de l'ensemble temp et qui, pour chaque carte, la place a l'emplacement l (incremente a chaque occuration) du tableau commun
                    begin
                        commun[l] := carte;
                        l := l + 1;
                    end;

                affichageMontrerCartes(commun, joueurs, j, j_actif, reveal);  // Appel de la procedure affichant au joueur j les cartes en commun avec l'hypothese et lui demandant quelle carte montrer
                montrer := True;  // Un joueur a montrer une de ses cartes
                SetLength(commun, 0);  // Liberation de l'espace memoire
            end
        else  // Sinon, affichage au joueur 'actif' que le joueur j ne possede aucune des cartes de son hypothese
            begin  
                colorPerso(joueurs, j);
                write(joueurs[j].perso);
                TextColor(15);
                writeln(' n''as aucune des cartes de votre hypothese.');
                Delay(1000);
            end;

        Inc(i);

        until (montrer OR (i = length(joueurs)));


    {Affiche au j_actif qu'aucun des joueurs ne possède les cartes de l'hypothèse si c'est le cas}
    if not(montrer) then  // Verfication du fait qu'un aucun joueur n'ait montre une de ses cartes
        writeln('Aucun des enqueteurs ne possede une carte de votre hypothese !');  // Si c'est le cas, affichage au joueur 'actif' que personne ne possede une carte de son hypothese
end;



procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro; plat : Plateau);
{Procedure permettant au joueur 'actif' de formuler une accusation}

var guess : Array [1..3] of ListeCartes;
    g1, g2, g3, carte : ListeCartes;
    perso, arme, lieu : set of ListeCartes;
    i : Integer;
    carteStr : String;

begin 
    perso := [];  // Initialisation de l'ensemble des personnages 
    arme := [];  // Initialisation de l'ensemble des armes
    lieu := [];  // Initialisation de l'ensemble des lieux
    if environnement = Manoir then  // Remplissage des ensembles perso, arme et lieu dans le cas de l'environnement Manoir
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
            for carte := Cuisine to Studio do
                Include(lieu, carte);
        end
    else  // Remplissage des ensembles perso, arme et lieu dans le cas de l'environnement INSA
        begin  
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
            for carte := Cafete to BU do
                Include(lieu, carte);
        end;


    ClrScr;
    affichageCartes(joueurs, j_actif);  // Appel de la procédure permettant d'afficher les cartes du joueur 'actif'


    writeln('Vous allez formuler une accusation !');

    repeat  // Boucle se repetant tant que le joueur 'actif' n'a pas rentré une carte valide
        write('Selon vous, qui est l''assassin ? ');
        readln(carteStr);
        if StrCorrect(carteStr) then  // Verification de la bonne saisie de la carte
            begin
                g1 := StrToListeCartes(carteStr);
                if not(g1 in perso) then  // Verification de la presence de la carte dans l'ensemble perso
                    writeln('La carte ne correspond pas a un personnage.');
            end
        else
            writeln('La saisie est incorrecte.');
        until ((g1 in perso) AND StrCorrect(carteStr));
    guess[1] := g1;  // La premiere valeur du tableau guess est le personnage que le joueur 'actif' soupçonne d'etre l'assassin

    repeat  // Boucle se repetant tant que le joueur 'actif' n'a pas rentré une carte valide
        write('Selon vous, quelle est l''arme du crime ? ');
        readln(carteStr);
        if StrCorrect(carteStr) then  // Verification de la bonne saisie de la carte
            begin
                g2 := StrToListeCartes(carteStr);
                if not(g2 in arme) then  // Verification de la presence de la carte dans l'ensemble arme
                    writeln('La carte ne correspond pas a une arme.');
            end
        else
            writeln('La saisie est incorrecte.');
        until ((g2 in arme) AND StrCorrect(carteStr));
    guess[2] := g2;  // La deuxieme valeur du tableau guess est l'arme que le joueur 'actif' soupçonne d'etre l'arme du crime

    repeat  // Boucle se repetant tant que le joueur 'actif' n'a pas rentré une carte valide
        write('Selon vous, dans quelle salle l''assassinat a-t-il eu lieu ? ');
        readln(carteStr);
        if StrCorrect(carteStr) then  // Verification de la bonne saisie de la carte
            begin
                g3 := StrToListeCartes(carteStr);  // Verification de la presence de la carte dans l'ensemble lieu
                if not(g3 in lieu) then
                    writeln('La carte ne correspond pas a un lieu.');
            end
        else
            writeln('La saisie est incorrecte.');
        until ((g3 in lieu) AND StrCorrect(carteStr));
    guess[3] := g3;  // La deuxieme valeur du tableau guess est le lieu que le joueur 'actif' soupçonne d'etre le lieu du crime

       
    i := 1;
    repeat  // Boucle se repetant tant que le joueur suspecté par le joueur 'actif' n'ai pas ete deplace dans la meme salle que ce dernier
        if (guess[1] = joueurs[i].perso) then  // Verification de la correspondance entre le joueur i et le joueur suspecte
            begin
                affiche(' ', joueurs[i].pos[1], joueurs[i].pos[2]);  // Appel de la procédure pour enlever le pion du joueur i du plateau
                joueurs[i].pos[1] := 14;  // Coordonnees de la salle 10
                joueurs[i].pos[2] := 18;     
                placementSalle(joueurs, plat, i);  // Appel de la procedure pour placer le joueur suspecte dans la salle 
                affiche(joueurs[i].pion, joueurs[i].pos[1], joueurs[i].pos[2]);  // Appel de la procédure pour afficher le pion du joueur suspecte sur le plateau
            end;
        Inc(i);
        until ((i = length(joueurs) + 1) OR (guess[1] = joueurs[i-1].perso));
   
   
   
    {Vérifie que les ensembles de l'accusation et de l'étui coincident, sinon le joueur du tour meurt}
    if ((etui[1] = guess[1]) AND (etui[2] = guess[2]) AND (etui[3] = guess[3])) then  // Verification de la coincidence entre l'accusation et l'etui
        accusation := True  // L'accusation est vraie
    else
        begin
            joueurs[j_actif].enVie := False;  // Sinon le joueur meurt
            ClrScr;
            write('Malheuresement, l''accusation de ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15);
            writeln(' n''etait pas la bonne. Il ne fait donc plus partie de l''enquete.');
        end;
end;



procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);
{Procedure mettant fin a la partie}
begin
    if accusation then  // Verification que l'accusation soit vraie, et si c'est le cas, le gagnant et les elements de l'etui sont affiches
        begin   
            writeln('La partie est terminee ! Un enqueteur a trouve le meurtrier, l''arme du crime et le lieu de l''assassinnat.');
            write('Et cet en enqueteur est ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15); 
            writeln(' !');
            write('Voici les elements du meurtre : ', ListeCartesToStr(etui[1]), ', ', ListeCartesToStr(etui[2]), ', ', ListeCartesToStr(etui[3]), '.');
        end
    else  // Sinon, l'enquete n'est pas resolue car tous les enqueteurs sont morts, donc les elements de l'etui sont affiches
        begin
            writeln('Aucun des enqueteurs n''est parvenu a resoudre ce meurtre. La partie est finie.');
            writeln('Voici les elements du meurtre : ', ListeCartesToStr(etui[1]), ', ', ListeCartesToStr(etui[2]), ', ', ListeCartesToStr(etui[3]), '.');
        end;
end;



procedure quitterSauvegarder(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; j_actif : Integer; environnement : Enviro);
{Procedure permmettant de sauvegarder la partie}

var nomFichier : String;
    nb_cartes, i, c : Integer;
    carte : ListeCartes;
    sauvegarde : Text;
    continue : Boolean;

begin
    writeln('Voulez-vous sauvegarder la partie en cours ?');  // Demande si il faut sauvegarder la partie
    writeln('   1 : Oui');
    writeln('   2 : Non');
    repeat  // Lecture du choix et vérification que l'action soit possible}
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas valide.')
    until ((c >= 1) AND (c <= 2));

    if (c = 1) then  // On choisit de sauvegarder
        begin
            write('Comment souhaitez-vous nommer votre sauvegarde (avec .txt en extension) : ');  // Demande le nom de fichier sauvegarde voulu
            continue := False;
            repeat  // Boucle se repetant jusqu'a ce que le nom fichier puisse etre valide
                readln(nomFichier);
                if FileExists(nomFichier) then  // Verfication de l'existance du fichier
                    begin
                        repeat  // Boucle se repetant jusqu'a ce que la variable c soit valide
                            writeln('Ce fichier existe deja. Voulez l''ecraser ou rentrer un autre nom ? ');
                            writeln('   1 : Ecraser');
                            writeln('   2 : Changer de nom');
                            write('Votre choix est : ');
                            readln(c);
                            if not((c >= 1) AND (c <= 2)) then  // Verification de la validite de la variable c
                                writeln('Ce choix n''est pas valide.');
                            until ((c >= 1) AND (c <= 2));

                        if (c = 1) then  // Si on choisie d'ecraser le fichier deja exisant, le nom  du fichier devient valide
                            continue := True;
                    end
                else  // Sinon, le nom du fichier est valide
                    continue := True;
                until (continue);


            assign(sauvegarde, nomFichier);  // Assignation du fichier sauvegarde
            rewrite(sauvegarde);  // Ecriture dans le dichier sauvegarde


            writeln(sauvegarde, environnement);  // Ecriture de l'environnement
            writeln(sauvegarde, length(joueurs));  // Ecriture du nombre de joueurs
            
            for i := 1 to length(joueurs) do  // Boucle parcourant tout les joueurs
                begin
                    writeln(sauvegarde, joueurs[i].enVie);  // Ecriture de l'etat de vie du joueur i
           
                    nb_cartes:= 0;
                    for carte in joueurs[i].cartes do  // Boucle comptant le nombre de carte du joueur i
                    nb_cartes:=nb_cartes + 1;

                    writeln(sauvegarde, nb_cartes);  // Ecriture du nombre de carte du joueur i
                    for carte in joueurs[i].cartes do  // Boucle parcourant les cartes du joueurs i
                        writeln(sauvegarde, carte);  // Ecriture des cartes du joueur i
           
                    writeln(sauvegarde, joueurs[i].pos[1]);  // Ecriture de l'a position du joueur i
                    writeln(sauvegarde, joueurs[i].pos[2]);

                    writeln(sauvegarde,  joueurs[i].perso);  // Ecriture du personnage du joueur i
                    writeln(sauvegarde,  joueurs[i].pion);
                end;
    
            for i := 1 to 3 do  // Boucle parcourant les elements de l'etui
                writeln(sauvegarde, etui[i]);  // Ecriture de l'etui

            writeln(sauvegarde, j_actif);  // Ecriture du joueur 'actif'


            close(sauvegarde);  // Fermeture du fichier
        end;
end;



function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;
{Fonction renvoyant la salle correspondant aux coordonnes saisies}

var co : Coords;
    i : Integer;

begin
    i := 1;  // Initialisation de la variable correspondant aux numeros des salles
    estDansLaSalle := 0;
    repeat  // Boucle se repetant jusqu'a ce que toute les salles aient ete verifiees ou qu'une salle corresponde
        for co in plat.salles[i].cases do  // Boucle parcourant les cases de la salle i
            begin
                if ((co[1] = coordonnees[1]) AND (co[2] = coordonnees[2])) then  // Verification de la correspondance entre les coordonnees saisies et celle de la salle i
                    estDansLaSalle := i;  // Si c'est le cas, la fonction renvoie la valeur de la salle correspondante
            end;
        Inc(i);
        until ((i = 11) OR (estDansLaSalle = i - 1));        
end;



function joueursEnVie(joueurs : ListeJoueurs) : Integer;
{Fonction renvoyant le nombre de joueur en vie}

var i : Integer;

begin
    {Renvoie le nombre de joueurs en vie}
    joueursEnVie := 0;
    for i := 1 to length(joueurs) do  //Boucle parcourant le tableau joueurs
        begin
            if (joueurs[i].enVie) then  // Verification de l'état de vie du joueur i
                joueursEnVie := joueursEnVie + 1;  // Si c'est le cas, le nombre total est incremente
        end;
end;



function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;
{Fonction renvoyant un booleen renseignant sur l'etat de liberte d'une case}

var i : Integer;

begin
    caseEstLibre := True;
    for i := 1 to length(joueurs) do  // Boucle parcourant le tableau joueurs
        begin
            if ((co[1] = joueurs[i].pos[1]) AND (co[2] = joueurs[i].pos[2])) then  // Verification de la correspondance entre la case renseignee et celle du joueur i
                caseEstLibre := False;  // Si c'est le cas, la case est occupee, donc pas disponible
        end;
end;



function sortieSallePossible(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;
{Fonction renvoyant une boolean renseignant sur la possibilite de sortir d'une salle}

var co1, co2, co3, co4 : Coords;

begin
    sortieSallePossible := True;
    case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
        2 : begin  // Le joueur 'actif' est dans la salle 2
                co1[1] := 11;  // Coordonnees de la sortie 1
                co1[2] := 10;

                co2[1] := 16;  // Coordonnees de la sortie 2
                co2[2] := 10;

                co3[1] := 9;  // Coordonnees de la sortie 3
                co3[2] := 7;

                co4[1] := 18;  // Coordonnees de la sortie 4
                co4[2] := 7;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2) AND caseEstLibre(joueurs, plat, co3) AND caseEstLibre(joueurs, plat, co4))) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
        4 : begin  // Le joueur 'actif' est dans la salle 4
                co1[1] := 8;  // Coordonnees de la sortie 1
                co1[2] := 18;

                co2[1] := 10;  // Coordonnees de la sortie 2
                co2[2] := 14;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
        5 : begin  // Le joueur 'actif' est dans la salle 5
                co1[1] := 24;  // Coordonnees de la sortie 1
                co1[2] := 15;

                co2[1] := 19;  // Coordonnees de la sortie 2
                co2[2] := 11;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
        6 : begin  // Le joueur 'actif' est dans la salle 6
                co1[1] := 22;  // Coordonnees de la sortie 1
                co1[2] := 15;

                co2[1] := 18;  // Coordonnees de la sortie 2
                co2[2] := 18;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
        8 : begin  // Le joueur 'actif' est dans la salle 8
                co1[1] := 14;  // Coordonnees de la sortie 1
                co1[2] := 19;

                co2[1] := 13;  // Coordonnees de la sortie 2
                co2[2] := 19;

                co3[1] := 17;  // Coordonnees de la sortie 3
                co3[2] := 22;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2) AND caseEstLibre(joueurs, plat, co3))) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
        10 : begin  // Le joueur 'actif' est dans la salle 10
                co1[1] := 14;  // Coordonnees de la sortie 1
                co1[2] := 19;

                if not(caseEstLibre(joueurs, plat, co1)) then  // Verification de la liberte de chaque sortie de la salle
                    sortieSallePossible := False;
            end;
    end;

end;


end.