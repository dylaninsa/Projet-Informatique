Unit partie;


Interface

uses unite, Crt, affichage;


procedure jeu(etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs);
procedure tour(plat : Plateau; etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);
{procedure finPartie(joueurs:ListeJoueurs; accusation:Boolean);}
{procedure quitterSauvegarder(joueurs:ListeJoueurs; plat:Plateau; etui:Array of ListeCartes; var sauvegarde:File);}
procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
procedure lancerDes(var lancer : Integer);
procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : Array of ListeCartes);
procedure demandeJoueur(hypo : Array of ListeCartes;joueurs : ListeJoueurs; j_actif : Integer);
procedure faireAccusation(etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);
function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;


Implementation



procedure jeu(etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs);

var j_actif : Integer;
    accusation : Boolean;
    key : Char;

begin
    ClrScr;
    accusation := False;

    j_actif := 1;
    repeat 
        begin 
            if (joueurs[j_actif].enVie) then
                tour(plat, etui, joueurs, accusation, j_actif);
            
            writeln('Appuyer sur ''Q'' pour quitter ou sur n''importe quelle autre touche pour continuer.');
            key := readKey();

            if (j_actif = length(joueurs)) then
                j_actif := 1
            else
                j_actif := j_actif + 1;
        
        end;
        until ((key = QUIT) OR accusation);
    
end;



function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;

var co : Coords;
    i : Integer;

begin
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
        until ((i = 10) OR estDansSalle);        

end;



procedure tour(plat : Plateau; etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);

var c, lancer : Integer;
    hypo : Array [1..3] of ListeCartes;
    continue : Char;

begin
    ClrScr;
    writeln('C''est à ', joueurs[j_actif].perso, ' de jouer !');
    affichageCartes(joueurs, j_actif);
    repeat
        continue := readKey();
        until (continue = #32);
    
    if (estDansSalle(joueurs, plat, j_actif)) then
        begin
            writeln('Que voulez-vous faire :');
            writeln('   1 : Vous déplacer');
            writeln('   2 : Formuler une hypothèse'); 
            writeln('   3 : Formuler une accusation');  

            repeat
                write('Votre choix est : ');
                readln(c);
                if not((c >= 1) AND (c <= 3)) then
                    writeln('Ce choix n''est pas disponible.')
                until ((c >= 1) AND (c <= 3));


            case c of
                1 : begin
                        lancerDes(lancer);
                        deplacement(plat, lancer, joueurs, j_actif);
                        if (estDansSalle(joueurs, plat, j_actif)) then
                            begin
                                faireHypothese(joueurs, hypo);
                                demandeJoueur(hypo, joueurs, j_actif);
                            end;
                    end;
                2 : begin
                        faireHypothese(joueurs, hypo);
                        demandeJoueur(hypo, joueurs, j_actif);
                    end;
                3 : begin
                        faireAccusation(etui, joueurs, accusation, j_actif);
                    end;
            end;
        end
    else
        begin
            lancerDes(lancer);
            deplacement(plat, lancer, joueurs, j_actif);
            if (estDansSalle(joueurs, plat, j_actif)) then
                begin
                    faireHypothese(joueurs, hypo);
                    demandeJoueur(hypo, joueurs, j_actif);
                end;
        end;
end;



{procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean);}
{procedure quitterSauvegarder(joueurs : ListeJoueurs; plat : Plateau; etui : Array of ListeCartes; var sauvegarde : File);}



procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);

var key : Char;
	cursorX, cursorY, move : Integer;

begin
    move := lancer;
    affichagePlateau(plat, joueurs);

    repeat
		begin
            Delay(500);
            cursorX := joueurs[j_actif].pos[1];
            cursorY := joueurs[j_actif].pos[2];
            affichageDeplacement(move);
			affiche(joueurs[1].pion, cursorX, cursorY);
			key := readKey();
            move := move - 1;
			case key of
				UP : if ((cursorY - 1 >= 2) AND (plat.grille[cursorX][cursorY - 1] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] - 1;
					end;
				DOWN : if ((cursorY + 1 <= 26) AND (plat.grille[cursorX][cursorY + 1] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] + 1;
					end;
				LEFT : if ((cursorX - 1 >= 2) AND (plat.grille[cursorX - 1][cursorY] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] - 1;
					end;
				RIGHT : if ((cursorX + 1 <= 25) AND (plat.grille[cursorX + 1][cursorY] <> 1)) then 
					begin
						affiche(' ', cursorX, cursorY);
                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] + 1;
					end;
			end ;
		end;
		until ((key = QUIT) OR (move = 0) OR estDansSalle(joueurs, plat, j_actif));
end;



procedure lancerDes(var lancer : Integer);

var de1, de2 : Integer;
    continue : Char;

begin
    Randomize;

    de1 := random(5) + 1;
    de2 := random(5) + 1;
    
    affichageDes(de1, de2);

    repeat
        continue := readKey();
        until (continue = #32);

    lancer := de1 + de2;
end;



procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes);

var g1, g2, g3 : ListeCartes;

begin 
    ClrScr;
    writeln('Vous allez formuler une hypothèse !');

    write('Selon vous, qui pourrait-être l''assassin ? ');
    readln(g1);
    hypo[1] := g1;

    write('Selon vous, quelle pourrait-être l''arme du crime ? ');
    readln(g2);
    hypo[2] := g2;

    write('Selon vous, dans quelle salle l''assassinat aurait-il pu avoir lieu  ? ');
    readln(g3);
    hypo[3] := g3;
end;



procedure demandeJoueur(hypo : array of ListeCartes; joueurs : ListeJoueurs; j_actif : Integer);

var i, j, k, l, nb : Integer;
    montrer : Boolean;
    commun : Array of ListeCartes;
    temp : set of ListeCartes;
    reveal, carte : ListeCartes;

begin
    i := 1;
    montrer := False;

    repeat 
        if (j_actif+i > length(joueurs)) then
            j := length(joueurs) - (length(joueurs) - i)
        else
            j := j_actif + i;
        writeln(hypo[3]);
        writeln(length(hypo));
        temp := [];
        for k := 1 to 3 do
            begin
                write(hypo[k], ' ');
                if (hypo[k] in joueurs[j].cartes) then
                    begin
                        Include(temp, hypo[k]);
                        writeln('In');
                    end
                else
                    writeln('Out');
            end;
        writeln('Oui');

        nb := 0;
        for carte in temp do
            nb := nb + 1;

        if (nb <> 0) then
            begin
                SetLength(commun, nb);
                l := 1;
                for carte in temp do
                    begin
                        commun[l] := carte;
                        l := l + 1;
                    end;

                affichageMontrerCartes(commun, joueurs, j, reveal);
                montrer := True;
                SetLength(commun, 0);
            end
        else
            writeln(joueurs[j].perso, ' n''as aucune des cartes de votre hypothèse.');

        
        i := i + 1;
        until (montrer OR (i = length(joueurs)));

    if (montrer) then
        writeln(joueurs[j_actif].perso, ', ', joueurs[j].perso, ' vous montre une de ses cartes, qui est ', reveal)
    else
        writeln('Aucun des joueurs de cette partie ne possède une carte de votre hypothèse !');
end;



procedure faireAccusation(etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);

var guess : Array [1..3] of ListeCartes;
    g : ListeCartes;

begin 
    writeln('Vous allez formuler une accusation !');

    write('Selon vous, qui est l''assassin ? ');
    readln(g);
    guess[1] := g;

    write('Selon vous, quelle est l''arme du crime ? ');
    readln(g);
    guess[2] := g;

    write('Selon vous, dans quelle salle l''assassinat a-t-il eu lieu  ? ');
    readln(g);
    guess[3] := g;


    if ((etui[1] = guess[1]) AND (etui[2] = guess[2]) AND (etui[3] = guess[3])) then
        accusation := True
    else
        joueurs[j_actif].enVie := False;
end;


end.