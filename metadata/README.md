# CroAI Code Club #01 — Metadata

Metapodaci i transkripti za **cc_01: Building a Real-Time Event Ticketing App** (Senko Rašić & Matija Stepanić), meetup održan **26.02.2026.** u organizaciji [CroAI](https://www.croai.org/).

---

## 1. Sirovi transkript (Rode Connect multichannel snimka)

**Datoteke:**
- `StereoMix.wav.txt` — plain text transkript
- `StereoMix.wav.srt` — SRT format istog transkripta

Transkript je napravljen na **sirovoj Rode Connect multichannel snimci** (StereoMix.wav) — bez ikakvog rezanja ili audio obrade.

### Whisper komanda

```bash
time /Users/ms/git/ggml-org/whisper.cpp/build/bin/whisper-cli \
  -m /Users/ms/git/ggml-org/whisper.cpp/models/ggml-large-v3-turbo.bin \
  -f /Volumes/DOMOVINA1TB/rode_connect_output/25.02.2026./StereoMix.wav \
  -l hr \
  -osrt \
  -t 4 \
  --prompt "$(cat /Volumes/DOMOVINA1TB/rode_connect_output/25.02.2026./whisper_prompt.txt)"
```

**Whisper prompt korišten** (iz `whisper_prompt.txt`):
```
CroAI,CroAI_Code_Club,Matija_Stepanić,Flutter,Firebase,Claude_Code,Firebase_Auth,
Cloud_Firestore,GitHub,Firebase_Hosting,ITalk_d.o.o.,Supabase,FlutterFlow,
CroAI_HQ,Zavrtnica_17,Live_Coding,Event_Ticketing_App,Zagreb
```

---

## 2. Analiza transkripta s LLM-ovima

Nakon transkripcije, transkript je analiziran s tri različita modela **koristeći identične promptove**, radi usporedbe kvalitete analize.

### 2.1. Gemini Fast (u browseru)
- **Chat:** [https://gemini.google.com/share/22dfd292dde9](https://gemini.google.com/share/22dfd292dde9)

### 2.2. Gemini Pro (u browseru)
- Paralelna usporedba kvalitete s identičnim promptovima
- **Chat:** [https://gemini.google.com/share/ab01d7eed262](https://gemini.google.com/share/ab01d7eed262)

### 2.3. Claude Opus 4.6 s Extended Thinkingom
- Identični promptovi kao Gemini varijante
- **Chat:** *(link share naknadno)*

---

## 3. YouTube upload i finalni transkript

### 3.1. Proces

1. Meetup je sustavno snimljen s **riverside.fm**
2. Snimka je exportana i uploadana na **YouTube**: [https://www.youtube.com/watch?v=MGLq9v3AtvE](https://www.youtube.com/watch?v=MGLq9v3AtvE)
3. Korišten je skup skripti s [domovinatv/fetch.domovina.tv](https://github.com/domovinatv/fetch.domovina.tv/tree/main) za:
   1. **Preuzimanje videa** s YouTube kanala
   2. **Generiranje whisper prompta** s LM Studio (lokalni LLM)
   3. **Lokalna transkripcija** s Whisperom

### 3.2. Finalni transkript

**Datoteke:**
- `20260226_cc_01_building_a_real_time_event_ticketing_app_senko_rasic_matija_stepanic_croai_code_club_yt_MGLq9v3AtvE.wav.srt` — finalni uredni SRT transkript
- `...description` — YouTube opis videa
- `..._whisper_prompt.txt` — LLM-generirani whisper prompt korišten za transkripciju

---

## 4. Usporedba kvalitete transkripata (Gemini)

Na temelju analize oba snimljena `.srt` filea u [Gemini chatu](https://gemini.google.com/share/c84c13d7e6fa), napravljena je kvantitativna i kvalitativna usporedba. Vrlo je jasno da se radi o istom događaju, ali je razlika u kvaliteti transkripcije drastična.

**Prvi transkript (YouTube video / Riverside)** djeluje kao rezultat puno preciznijeg prepoznavanja govora, dok **drugi transkript (StereoMix.wav)** izgleda kao sirovi izlaz modela koji se mučio s pozadinskom bukom, hvatanjem konteksta i fragmentiranim rečenicama.

Ispod haube je u oba slučaja korišten isti model (**Whisper Large v3**), ali su ulazni signal i kontekst (prompt) stvorili ogromnu razliku — savršen *case study* zašto sirovi AI model nije dovoljan sam po sebi, već je *pipeline* oko njega ključan.

### 4.1. Usporedba po kategorijama (0-100)

| Kategorija | 1. Transkript (YouTube) | 2. Transkript (StereoMix) | Razlog razlike |
| --- | --- | --- | --- |
| **Koherentnost i tijek rečenica** | **90** | **40** | Prvi transkript slaže smislene cjeline. Drugi na početku hvata nepovezane riječi i pozadinski žamor. |
| **Prepoznavanje entiteta (Imena i tehnologije)** | **95** | **60** | Prvi savršeno hvata specifična imena i tech koncepte ("git log", "vibe coding"). Drugi je siromašniji entitetima. |
| **Pouzdanost (Odsutnost halucinacija)** | **85** | **45** | Drugi transkript povremeno "halucinira" tekst pokušavajući interpretirati šumove ili tihe razgovore iz publike. |
| **Čitljivost za krajnjeg korisnika** | **90** | **35** | Prvi transkript je iznimno čitljiv i gledatelj bi s lakoćom pratio predavanje. Drugi bi gledatelja potpuno zbunio zbog isjeckanih fraza. |
| **UKUPNI DOJAM (Prosjek)** | **90 / 100** | **45 / 100** | Prvi file je iznimno upotrebljiv, dok bi drugi zahtijevao kompletnu manualnu reviziju. |

### 4.2. Zaključak

* **Zašto je Riverside + Prompt transkript briljirao (90/100):** Kvaliteta izvornog zvuka (čist audio bez gubitaka) gdje Whisper dobiva jasan signal za analizu i **moć prompta** (zadan stil i ključni programerski pojmovi su "prime-ali" model da prestane nagađati).
* **Zašto se Rode Connect "smeće" raspalo (45/100):** Šum i pozadinski žamor uzrokuju probleme jer Whisper pod svaku cijenu pokušava "čuti" govor i u tišinama. Tada halucinira izmišljajući fraze iz neartikuliranog šuma. Ovo je školski primjer *garbage in, garbage out* pravila u AI svijetu.

---

## 5. Datoteke u ovom folderu

| Datoteka | Opis |
|---|---|
| `SOCIAL.md` | Statistike objava na društvenim mrežama |
| `StereoMix.wav.txt` | Sirovi transkript (Rode Connect, plain text) |
| `StereoMix.wav.srt` | Sirovi transkript (Rode Connect, SRT format) |
| `whisper_prompt.txt` | Ručni whisper prompt za sirovu snimku |
| `...yt_MGLq9v3AtvE.wav.srt` | Finalni YouTube transkript (SRT) |
| `...yt_MGLq9v3AtvE.description` | YouTube video opis |
| `...yt_MGLq9v3AtvE_whisper_prompt.txt` | LLM-generirani whisper prompt za YouTube video |
