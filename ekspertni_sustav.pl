:- dynamic odgovor/2.
:- dynamic odabrano/2.

komponenta(procesor, 'AMD Athlon 3000G',    slaba,    75).
komponenta(procesor, 'Intel Pentium Gold',  slaba,    90).
komponenta(procesor, 'AMD Ryzen 3 4100',    slaba,   120).
komponenta(procesor, 'Intel Core i3-12100', slaba,   130).
komponenta(procesor, 'AMD Ryzen 5 5600',    srednja, 165).
komponenta(procesor, 'Intel Core i5-12400', srednja, 190).
komponenta(procesor, 'AMD Ryzen 5 7600',    srednja, 220).
komponenta(procesor, 'Intel Core i5-14600', srednja, 300).
komponenta(procesor, 'AMD Ryzen 7 7700X',   jaka,    350).
komponenta(procesor, 'Intel Core i7-14700', jaka,    420).
komponenta(procesor, 'AMD Ryzen 9 7900X',   jaka,    480).
komponenta(procesor, 'Intel Core i9-14900', jaka,    620).

komponenta(graficka, 'Integrirana grafika', slaba,     0).
komponenta(graficka, 'NVIDIA GT 1030',      slaba,    80).
komponenta(graficka, 'AMD RX 6400',         slaba,   130).
komponenta(graficka, 'NVIDIA RTX 3050',     srednja, 230).
komponenta(graficka, 'AMD RX 6600',         srednja, 250).
komponenta(graficka, 'NVIDIA RTX 4060',     srednja, 330).
komponenta(graficka, 'AMD RX 7800 XT',      jaka,    520).
komponenta(graficka, 'NVIDIA RTX 4070',     jaka,    550).
komponenta(graficka, 'AMD RX 7900 XTX',     jaka,    950).
komponenta(graficka, 'NVIDIA RTX 4080',     jaka,   1000).

komponenta(memorija, '8 GB RAM',     8,  25).
komponenta(memorija, '16 GB RAM',   16,  45).
komponenta(memorija, '32 GB RAM',   32,  85).
komponenta(memorija, '64 GB RAM',   64, 200).
komponenta(memorija, '128 GB RAM', 128, 420).

komponenta(disk, '256 GB SSD',  256,  30).
komponenta(disk, '512 GB SSD',  512,  45).
komponenta(disk, '1 TB SSD',   1000,  75).
komponenta(disk, '2 TB SSD',   2000, 140).
komponenta(disk, '4 TB SSD',   4000, 280).
komponenta(disk, '8 TB SSD',   8000, 550).

vrsta_komponente(procesor).
vrsta_komponente(graficka).
vrsta_komponente(memorija).
vrsta_komponente(disk).

cijena_osnove(150).

zahtjev(ured,          slaba,   slaba,    8,  256).
zahtjev(skola,         slaba,   slaba,    8,  256).
zahtjev(programiranje, srednja, slaba,   16,  512).
zahtjev(igre,          srednja, jaka,    16, 1000).
zahtjev(obrada_videa,  jaka,    jaka,    32, 2000).

razina(slaba,   1).
razina(srednja, 2).
razina(jaka,    3).

dovoljno(X, Y) :-
    razina(X, RX),
    razina(Y, RY),
    RX >= RY.

minimalno(procesor, Namjena, Min) :- zahtjev(Namjena, Min, _, _, _).
minimalno(graficka, Namjena, Min) :- zahtjev(Namjena, _, Min, _, _).
minimalno(memorija, Namjena, Min) :- zahtjev(Namjena, _, _, Min, _).
minimalno(disk,     Namjena, Min) :- zahtjev(Namjena, _, _, _, Min).

zadovoljava_min(Razina, Min) :-
    razina(Razina, _), !,
    dovoljno(Razina, Min).
zadovoljava_min(Broj, Min) :-
    number(Broj),
    Broj >= Min.

prikladna(Vrsta, Namjena, Naziv) :-
    komponenta(Vrsta, Naziv, Razina, _),
    minimalno(Vrsta, Namjena, Min),
    zadovoljava_min(Razina, Min).

najjeftinija(Vrsta, Min, Naziv) :-
    findall(Cijena-N,
            ( komponenta(Vrsta, N, Razina, Cijena),
              zadovoljava_min(Razina, Min) ),
            Lista),
    sort(Lista, [_-Naziv|_]).

dio_konfiguracije(Vrsta, Naziv) :-
    odabrano(Vrsta, Naziv).
dio_konfiguracije(Vrsta, Naziv) :-
    \+ odabrano(Vrsta, _),
    odgovor(namjena, Namjena),
    minimalno(Vrsta, Namjena, Min),
    najjeftinija(Vrsta, Min, Naziv).

ukupna_cijena(Ukupno) :-
    findall(Cijena,
            ( vrsta_komponente(Vrsta),
              dio_konfiguracije(Vrsta, Naziv),
              komponenta(Vrsta, Naziv, _, Cijena) ),
            Cijene),
    sum_list(Cijene, Zbroj),
    cijena_osnove(Osnova),
    Ukupno is Zbroj + Osnova.

najjeftinija_konfiguracija(Namjena, Ukupno) :-
    findall(Cijena,
            ( vrsta_komponente(Vrsta),
              minimalno(Vrsta, Namjena, Min),
              najjeftinija(Vrsta, Min, Naziv),
              komponenta(Vrsta, Naziv, _, Cijena) ),
            Cijene),
    sum_list(Cijene, Zbroj),
    cijena_osnove(Osnova),
    Ukupno is Zbroj + Osnova.

ispod_preporuke(Vrsta, Naziv, Min) :-
    odgovor(namjena, Namjena),
    odabrano(Vrsta, Naziv),
    komponenta(Vrsta, Naziv, Razina, _),
    minimalno(Vrsta, Namjena, Min),
    \+ zadovoljava_min(Razina, Min).

ispisi_konfiguraciju :-
    odgovor(namjena, Namjena),
    odgovor(budzet, Budzet),
    format('~n---------------------------------------------------~n'),
    format('PREDLOZENA KONFIGURACIJA (stolno racunalo, namjena: ~w):~n',
           [Namjena]),
    forall(vrsta_komponente(Vrsta), ispisi_dio(Vrsta)),
    cijena_osnove(Osnova),
    format('  * kuciste, maticna ploca i napajanje - ~w EUR~n', [Osnova]),
    ukupna_cijena(Ukupno),
    format('UKUPNA CIJENA: ~w EUR (budzet: ~w EUR)~n', [Ukupno, Budzet]),
    (   Ukupno =< Budzet
    ->  format('Konfiguracija je unutar budzeta.~n')
    ;   Razlika is Ukupno - Budzet,
        format('Konfiguracija premasuje budzet za ~w EUR!~n',
               [Razlika]),
        savjet_za_budzet(Namjena, Budzet)
    ),
    ispisi_upozorenja,
    objasni(Namjena).

ispisi_dio(Vrsta) :-
    dio_konfiguracije(Vrsta, Naziv),
    komponenta(Vrsta, Naziv, Razina, Cijena),
    (   odabrano(Vrsta, Naziv)
    ->  Izvor = 'korisnik'
    ;   Izvor = 'sustav'
    ),
    format('  * ~w: ~w (~w) - ~w EUR  [~w]~n',
           [Vrsta, Naziv, Razina, Cijena, Izvor]).

savjet_za_budzet(Namjena, Budzet) :-
    najjeftinija_konfiguracija(Namjena, Najjeftinija),
    (   Najjeftinija =< Budzet
    ->  format('Savjet: prepustite li sve komponente sustavu, cijena je ~w EUR.~n',
               [Najjeftinija])
    ;   format('UPOZORENJE: ni najjeftinija konfiguracija za namjenu "~w" (~w EUR)~n',
               [Namjena, Najjeftinija]),
        format('        ne stane u budzet od ~w EUR, povecajte budzet.~n',
               [Budzet])
    ).

ispisi_upozorenja :-
    forall(ispod_preporuke(Vrsta, Naziv, Min),
           format('UPOZORENJE: ~w "~w" je ispod preporuke (barem ~w)!~n',
                  [Vrsta, Naziv, Min])).

objasni(Namjena) :-
    zahtjev(Namjena, MinProc, MinGraf, MinRam, MinDisk),
    format('~nObjasnjenje:~n'),
    format('  - namjena "~w" trazi barem:~n', [Namjena]),
    format('      procesor ~w, grafika ~w, ~w GB RAM, ~w GB disk~n',
           [MinProc, MinGraf, MinRam, MinDisk]),
    format('  - komponente koje niste odabrali sustav bira kao najjeftinije~n'),
    format('    koje jos uvijek zadovoljavaju te minimalne zahtjeve~n'),
    format('  - podrazumijeva se stolno racunalo, pa je u cijenu ukljucena~n'),
    format('    osnova (kuciste, maticna ploca i napajanje)~n').
