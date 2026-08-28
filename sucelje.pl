:- ensure_loaded('ekspertni_sustav.pl').

:- use_module(library(pce)).

sucelje :-
    new(D, dialog('Konfigurator stolnog racunala')),

    send(D, append,
         label(napomena,
               'Sastavljanje stolnog racunala od pojedinacnih komponenti.')),

    new(MeniNamjena, menu(namjena, cycle)),
    send_list(MeniNamjena, append,
              [ured, skola, programiranje, igre, obrada_videa]),
    send(D, append, MeniNamjena),

    new(PoljeBudzet, int_item(budzet_eur, 1200)),
    send(D, append, PoljeBudzet),

    napravi_meni_komponente(procesor, MeniProc),
    send(D, append, MeniProc),
    napravi_meni_komponente(graficka, MeniGraf),
    send(D, append, MeniGraf),
    napravi_meni_komponente(memorija, MeniMem),
    send(D, append, MeniMem),
    napravi_meni_komponente(disk, MeniDisk),
    send(D, append, MeniDisk),

    new(Prikaz, editor),
    send(Prikaz, size, size(78, 20)),
    send(Prikaz, editable, @off),

    send(D, append,
         button(sastavi_konfiguraciju,
                message(@prolog, gui_konfiguracija,
                        MeniNamjena?selection,
                        PoljeBudzet?selection,
                        MeniProc?selection,
                        MeniGraf?selection,
                        MeniMem?selection,
                        MeniDisk?selection,
                        Prikaz))),

    send(D, append,
         button(ponisti_odabire,
                message(@prolog, gui_ponisti,
                        MeniProc, MeniGraf, MeniMem, MeniDisk, Prikaz))),

    send(D, append, button(izlaz, message(D, destroy))),

    send(D, append, Prikaz),
    send(D, open).

napravi_meni_komponente(Vrsta, Meni) :-
    new(Meni, menu(Vrsta, cycle)),
    send(Meni, append, sustav_predlaze),
    forall(komponenta(Vrsta, Naziv, _, _),
           send(Meni, append, Naziv)).

gui_konfiguracija(Namjena, Budzet, Proc, Graf, Mem, Disk, Prikaz) :-
    retractall(odgovor(_, _)),
    retractall(odabrano(_, _)),
    assertz(odgovor(namjena, Namjena)),
    assertz(odgovor(budzet, Budzet)),
    zapamti_odabir(procesor, Proc),
    zapamti_odabir(graficka, Graf),
    zapamti_odabir(memorija, Mem),
    zapamti_odabir(disk, Disk),
    with_output_to(string(Tekst), ispisi_konfiguraciju),
    send(Prikaz, clear),
    send(Prikaz, append, Tekst),
    send(Prikaz, caret, 0),
    send(Prikaz, scroll_to, 0).

zapamti_odabir(_, sustav_predlaze) :- !.
zapamti_odabir(Vrsta, Naziv) :- assertz(odabrano(Vrsta, Naziv)).

gui_ponisti(MeniProc, MeniGraf, MeniMem, MeniDisk, Prikaz) :-
    retractall(odabrano(_, _)),
    forall(member(Meni, [MeniProc, MeniGraf, MeniMem, MeniDisk]),
           send(Meni, selection, sustav_predlaze)),
    send(Prikaz, clear).

:- initialization(sucelje).
