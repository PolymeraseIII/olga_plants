## Olga kiełkowanie
### Ocena jakości zmiennych
Poniżej przedstawiono wykresy przedstawiające średnie arytmetyczne z długości łodygi w zależności od stężenia wyciągu wodnego dla poszczególnych gatunków roślin oraz 95% przedział ufności dla średniej. Wykresy są pogrupowane zmienną kategoryczną oznaczającą dzień pomiaru, przedstawioną w ramce nad wykresem.

![](plots/burak.png)
![](plots/jeczmien.png)
![](plots/owies.png)
![](plots/pszenica.png)
![](plots/rzepak.png)
![](plots/rzeżucha.png)
![](plots/salata.png)
![](plots/sosna.png)

Ze względu na nieścisłości w danych (mniejsze wartości długości łodygi dla kolejnych dni bądź braki danych) zaprzestano dalszej analizy dla gatunków: 

- burak,
- rzepak,
- sałata,
- sosna.

W trakcie analizy wykresów należy także zauważyć wysokie wartości 95% przedziału ufności dla gatunków owies i jęczmień, co w następstwie może skutkować nieistotnymi wynikami testów statystycznych opartych na średniej arytmetycznej.

### Normalność rozkładu zmiennych

Zmienne zostały ocenione pod kątem zgodności z rozkładem normalnym za pomocą testu Shapiro-Wilka. Zostały wykonane wwykresy kwantyl-kwantyl (ang. *qq plots*) obrazujące zgodność danych z rozkładem normalnym. Na podstawie przeprowadzonego testu we wszystkich przypadkach odrzucono hipotezę zerową o zgodności danych z rozkładem normalnym. Z tego powodu do dalszej analizy wybrano testy  nieparametryczne.

![](plots/normality/jeczmien_qqplot.png)
![](plots/normality/owies_qqplot.png)
![](plots/normality/pszenica_qqplot.png)
![](plots/normality/rzeżucha_qqplot.png)

### Test sumy rang Wilcoxona

Dane zanalizowane zostały testem nieparametrycznym znakowanych rang Wilcoxona w celu sprawdzenia różnic pomiędzy poszczególnymi stężeniami, a kontrolą, odrębnie dla każdej rośliny i każdego dnia. Przedstawiono je na wykresach, kolejno dla:

![](plots/pubr/jeczmien_pubr.png)
*Jęczmień, poziomy istotności oznaczono: ns: p > 0.05, \*: p <= 0.05,  \*\*: p <= 0.01, \*\*\*: p <= 0.001, \*\*\*\*: p <= 0.0001.*

* * *

![](plots/pubr/owies_pubr.png)
*Owies, poziomy istotności oznaczono: ns: p > 0.05, \*: p <= 0.05,  \*\*: p <= 0.01, \*\*\*: p <= 0.001, \*\*\*\*: p <= 0.0001.*

* * *

![](plots/pubr/pszenica_pubr.png)
*Pszenica, poziomy istotności oznaczono: ns: p > 0.05, \*: p <= 0.05,  \*\*: p <= 0.01, \*\*\*: p <= 0.001, \*\*\*\*: p <= 0.0001.*

* * *

![](plots/pubr/rzeżucha_pubr.png)
*Rzeżucha, poziomy istotności oznaczono: ns: p > 0.05, \*: p <= 0.05,  \*\*: p <= 0.01, \*\*\*: p <= 0.001, \*\*\*\*: p <= 0.0001.*

* * *

Uzyskane w wyniku testu Wilcoxona wartości poziomu istotności p przedstawiono na heatmapie:

![](plots/pubr/pval_pubr.png)
