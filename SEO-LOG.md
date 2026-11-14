# SEO Log – shreesawriyasolutions.in

Running log of SEO work, so the same thing isn't done twice. Newest at the bottom.

## 2026-11-02 – Indexing fixes
- Footer links to all public pages on every public page (internal linking).
- FAQ section added to booking.html (page was too thin to index).
- Custom 404.html (noindex) added.
- card.html marked noindex and removed from sitemap.

## 2026-11-02 – Page speed: photo compression
- Research: searches like "mobile repair Assandh" show almost no strong local competitor websites; results are mostly unrelated directories. Many local listings spell the town "Asandh".
- Change: resized gallery and Our Works photos to max 1600px and recompressed them. Total photo weight went from about 10.7 MB to about 1.8 MB. work1.png (1.3 MB photo) converted to work1.jpg (174 KB) and our-works.json updated.
- Added alt text to the header logo on index.html.
- Why: home page loads these photos on mobile data; faster pages rank better and fewer visitors leave.

### Ideas for future days
- Future photos: keep them under about 300 KB (max 1600px wide) before adding to gallery/ or our-works/.
- Mention the "Asandh" spelling once naturally (e.g. address line) so both spellings match.
- Service structured data (Service / OfferCatalog) on iphone-repair and android-repair pages, matching visible content.
- Hindi and Punjabi versions of the booking FAQ.
- Owner actions: Google Business Profile weekly photo/post, ask happy customers for Google reviews, consistent name-address-phone on Justdial/IndiaMART.

## 2026-11-02 – Photo framing (Gallery + Our Works)
- Every gallery/our-works photo is now a 1600x1000 (16:10) JPEG matching the carousel frame. Photos that weren't 16:10 are shown whole on a dimmed, blurred copy of themselves (no text or faces cut off), instead of black bars.
- New photos should be framed the same way (16:10, about 1600x1000, under about 300 KB) before adding them.

## 2026-11-03 – Service structured data + one business identity
- Research: searched "iPhone repair Asandh Karnal" and "mobile repair training Karnal Haryana chip level". Results are still mostly unrelated forums and IndiaMART training listings (Delhi/other cities); no strong local repair website ranks for Assandh. Training searches are dominated by IndiaMART, so a consistent IndiaMART/Justdial listing would help.
- Change: added Service JSON-LD (with an OfferCatalog of the diagnosis categories already shown on the page, no prices) to iphone-repair.html and android-repair.html. Added the same "@id" (https://shreesawriyasolutions.in/#business) to the LocalBusiness block on every public page (and the Course provider on training.html), so Google treats them as one business instead of five separate ones. Service provider points to that @id.
- Sitemap lastmod updated for iphone-repair and android-repair.
- Why: helps Google understand exactly which repairs the shop does on each page and connect them to the one business/Maps listing.

### Ideas for future days
- Mention the "Asandh" spelling once naturally (still pending).
- postalCode in the address JSON-LD (verify the PIN with the owner first; don't guess).
- Hindi/Punjabi versions of the booking FAQ.
- Visible FAQ on training.html (only from facts already on the page) + FAQPage JSON-LD.

## 2026-11-04 – Training page FAQ
- Research: searched "mobile repairing course Karnal Assandh chip level training". Results are all IndiaMART, coursetakers.com and institutes in other cities; no local training centre in Assandh/Karnal ranks with its own page. Course pages that rank answer basic questions (who can join, what you learn, how to ask about fees).
- Change: added a visible "Mobile Repair Training – FAQ" section on training.html (5 questions: location, joining without experience, which level for technicians, iPhone training, how to ask about fees/duration/timings) plus matching FAQPage JSON-LD. Every answer uses only facts already on the site (no fees, durations, batch timings or certificates invented). Location answer mentions "Asandh" spelling once (pending idea done). FAQ links to iphone-repair and android-repair pages.
- Sitemap lastmod for training.html set to 2026-11-04.
- Why: gives the thin-on-text training page real answers for "mobile repair course Karnal/Assandh" style searches and helps Google understand the course levels.

### Ideas for future days
- If the owner shares course duration/fees/batch timings or certificate details, add them to the training page and FAQ (only with his confirmation).
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.
- training.html has no language switcher; consider later only if the owner wants it.
- Owner action idea: IndiaMART listing for the training (training searches are dominated by IndiaMART), same name-address-phone.

## 2026-11-05 – Breadcrumb structured data
- Research: searched "mobile phone repair shop Assandh Karnal" and "Android mobile repair near Assandh Safidon Jind". Results are still directory pages (Flipkart service pages, explurger, ueni, Google Sites listings) — no strong local repair website. The site already has the best on-page local signals; the gap is off-site (Google Business Profile, reviews, listings).
- Change: added BreadcrumbList JSON-LD (Home > page) to iphone-repair.html, android-repair.html, training.html and booking.html. Matches the visible Home/back link on each page. No visible content changed, so sitemap lastmod not touched.
- Why: lets Google show "shreesawriyasolutions.in › iPhone Repair in Assandh" style breadcrumbs in results and makes the site structure clearer.

### Ideas for future days
- H1 on iphone-repair/android-repair is generic ("Complete iPhone Repair Solutions"); a local H1 like "iPhone Repair in Assandh" would help, but it needs matching data-en/data-hi/data-pa text — only do it carefully (or with owner OK) since it touches the language switcher text.
- Short visible intro paragraph on android-repair.html naming brands (Samsung, Vivo, Oppo, etc. are already in og:description) — also needs hi/pa translations.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.

## 2026-11-06 – Local H1 headings on repair pages
- Research: searched "mobile repair shop Assandh Karnal" and "phone screen replacement battery replacement Karnal Panipat". Results are still Flipkart city pages, explurger/ueni/Quikr directory listings and unrelated Assandh service centres (trucks, cars, bikes). No local repair website competes; on-page local signals matter, plus off-site listings.
- Change: H1 on iphone-repair.html "Complete iPhone Repair Solutions" → "iPhone Repair in Assandh"; on android-repair.html "Complete Android Repair Solutions" → "Android Phone Repair in Assandh". Updated data-en/data-hi/data-pa together (हिंदी: "असंध में आईफोन/एंड्रॉयड फोन रिपेयर", ਪੰਜਾਬੀ: "ਅਸੰਧ ਵਿੱਚ ਆਈਫੋਨ/ਐਂਡਰਾਇਡ ਫੋਨ ਰਿਪੇਅਰ"); switcher code untouched. H1 now matches each page's title tag.
- Sitemap lastmod for both pages set to 2026-11-06.
- Why: the H1 is the strongest on-page heading; generic "Complete ... Solutions" said nothing about the place. Now page title, H1 and breadcrumb all point to the same local search.

### Ideas for future days
- Short visible intro paragraph on android-repair.html naming brands (Samsung, Vivo, Oppo, etc. are in og:description) — needs hi/pa translations.
- Add width/height to the header logo <img> on subpages (avoids layout shift).
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.

## 2026-11-07 – Brand names visible on Android page
- Research: searched "mobile repair shop Assandh Karnal" and "Samsung Vivo Oppo mobile repair Karnal Assandh". Results are still Flipkart city pages, Cashify Karnal stores, brand service-centre lists (gsmspecs) and directory listings (explurger, ueni, Quikr). Brand + town searches ("Vivo repair Karnal") are a real pattern, but our page only named the brands in og/twitter meta (not visible to Google as page text).
- Change: added one short visible line under the hero on android-repair.html: "We repair Samsung, OnePlus, Xiaomi, Vivo, Oppo and Realme phones at our shop in Assandh, Karnal." with data-en/data-hi/data-pa translations (same brand list already in the page's og:description; nothing new claimed). Switcher code untouched.
- Sitemap lastmod for android-repair.html set to 2026-11-07.
- Why: brand names in visible text let the page match "Samsung/Vivo/Oppo repair Assandh/Karnal" searches.

### Ideas for future days
- Add width/height to the header logo <img> on subpages (avoids layout shift) — still pending.
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.

## 2026-11-08 – Page speed: small logo file
- Research: searched "mobile repair shop Assandh Karnal" again. Same picture as before: Flipkart city pages, explurger/ueni/Quikr/Google Sites listings and unrelated Assandh vehicle service centres. No local repair website competes, so speed and off-site listings are the main levers.
- Change: logo.png is 500x500 / 97 KB but is shown at only 34–64 px. Added logo-128.png (128x128, about 12 KB, sharp on 2x screens) and used it for every visible logo <img> (navbar, footer, index splash) on the 5 public pages. Added width="36" height="36" to the navbar logo on the 4 subpages (pending idea; avoids layout shift). logo.png kept as-is for favicon, og:image, twitter:image and JSON-LD logo/image.
- No visible text changed, so sitemap lastmod not touched.
- Why: saves about 85 KB on every page load on mobile data; faster first paint helps mobile rankings.

### Ideas for future days
- Favicon/apple-touch-icon still point to the 97 KB logo.png; a small favicon (e.g. 48px/180px) could be added later.
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.

## 2026-11-09 – Small favicon and apple-touch-icon
- Research: searched "mobile repair Panipat Kaithal Assandh shop". Same picture: Flipkart city pages, IndiaMART directory, Cashify stores, explurger/ueni/bino.bot listings. No local repair website competes; speed and off-site listings remain the main levers.
- Change: favicon and apple-touch-icon on the 5 public pages pointed to the 97 KB, 500x500 logo.png. Added favicon-48.png (48x48, ~3 KB; Google wants favicons in multiples of 48px) and apple-touch-icon.png (180x180 on white, ~13 KB), and pointed the <link rel="icon"> / <link rel="apple-touch-icon"> tags to them with sizes. logo.png kept for og:image, twitter:image and JSON-LD. Admin pages untouched.
- No visible text changed, so sitemap lastmod not touched.
- Why: saves another ~85 KB download per new visitor on mobile data and gives Google a correctly sized favicon for search results.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.

## 2026-11-10 – Local title and meta description on training page
- Research: searched "mobile repair shop Assandh Karnal iPhone repair" and "mobile repairing course Karnal". Repair results are the same Flipkart city pages and explurger/ueni/Google Sites listings. Course results are coursetakers.com, careers360 and Udemy pages; no local Karnal/Assandh training page ranks. People search "mobile repairing course + city", but training.html was the only public page whose title had no place name.
- Change: training.html title/og:title/twitter:title "Chip-Level Mobile Repair Training | Shree Sawriya Solutions" → "Mobile Repairing Course in Assandh, Karnal | Shree Sawriya Solutions". Meta description rewritten to name Assandh, Karnal and the four courses already shown on the page (basic, Android, iPhone hardware, advanced chip-level). Nothing new claimed; H1, visible text and JSON-LD unchanged.
- Sitemap lastmod not touched (no visible content change).
- Why: title is the strongest ranking/click signal; it now matches the real search wording ("mobile repairing course", page already uses "Basic Mobile Repairing Course") plus the town.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere (index mentions iPhone 12 in a review/text only).
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.
- Owner action idea: IndiaMART/Justdial listing for the training with the same name-address-phone.

## 2026-11-10 (later, owner request) – Google Business Profile link
- Owner says the Google Business Profile is now verified and shared its link: https://g.page/r/CcHxO3bTgz8UEBE/
- Change: index.html "Write a Review on Google" button now opens the direct review form (https://g.page/r/CcHxO3bTgz8UEBE/review) instead of the Maps place page, so customers get the star/review box in one tap. Added the g.page link to LocalBusiness "sameAs" JSON-LD. Button text, translations and the live reviews script untouched.
- Owner told what to fill in the profile (categories, services, description from site facts, photos, review link to customers, weekly posts).

## 2026-11-11 – FAQPage structured data on booking page
- Research: searched "mobile repair shop Assandh Karnal screen replacement". Same picture as before: Flipkart city pages (Karnal, Panipat), explurger/ueni/Google Sites listings and unrelated shops; no local repair website competes. Off-site signals (Google Business Profile, reviews, listings) remain the main lever.
- Change: booking.html already had a visible 5-question "Free Phone Diagnosis – FAQ" (added 2026-11-02) but no FAQPage JSON-LD. Added FAQPage JSON-LD generated directly from the visible questions/answers (same wording, links stripped). No visible content changed; form, WhatsApp buttons and switcher untouched; sitemap lastmod not touched.
- Why: helps Google understand the page's answers (free diagnosis, brands, timings, location in Assandh, Karnal) and makes the booking page consistent with training.html, which already has FAQPage markup. Note: Google shows FAQ rich results only for a few site types now, so this is mainly for understanding, not a guaranteed snippet.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-12 – Local title and meta description on booking page
- Research: searched "mobile repair shop Assandh Karnal". Same picture: Flipkart city pages (Karnal), Quikr Karnal, explurger/ueni/Google Sites listings and unrelated Assandh vehicle service centres. No local repair website competes; on-page local signals plus Google Business Profile/reviews remain the levers.
- Change: booking.html was the only public page whose title had no place name ("Book a Mobile Repair Appointment"). Title/og:title/twitter:title → "Free Phone Diagnosis & Repair Booking in Assandh | Shree Sawriya Solutions" (matches the page's H1 "FREE Phone Diagnosis"). Meta description rewritten from page facts (free diagnosis, Salwan Chowk, Assandh, Karnal, date/time slot, WhatsApp booking); og/twitter descriptions "Assandh, Haryana" → "Assandh, Karnal". Nothing new claimed; visible text, form, WhatsApp button, switcher and JSON-LD untouched.
- Sitemap lastmod not touched (no visible content change).
- Why: all 5 public pages now carry a local keyword in the title; "free phone diagnosis Assandh" / "mobile repair booking Assandh" now match the title.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi versions of the booking FAQ.
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-13 – Hindi/Punjabi translations for the booking FAQ
- Research: searched "iPhone battery replacement Karnal Assandh shop". Results are Flipkart's Karnal repair page, Apple support pages and shops in other countries/cities; no local repair website competes. On-page basics (local titles on all 5 pages, JSON-LD, small images) are done, so today went to a long-pending usability item for local Hindi/Punjabi-speaking visitors.
- Change: the visible "Free Phone Diagnosis – FAQ" on booking.html (heading, 5 questions, 5 answers) was English-only, so the page's हिंदी/ਪੰਜਾਬੀ switcher left it in English. Added data-en/data-hi/data-pa to each element (same facts as the English text; site's existing spellings for असंध/ਅਸੰਧ and brand names used). The answer with links was split into small spans so the iPhone/Android repair links stay working after switching. English text is byte-for-byte the same on screen (checked in headless Chromium: EN identical, HI/PA translate, links kept). Switcher code, form, WhatsApp button and FAQPage JSON-LD untouched.
- Sitemap lastmod not touched (default English content unchanged).
- Why: visitors who read Hindi/Punjabi now get the whole booking page in their language, which helps them book instead of bouncing.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Check other public pages for English-only blocks the switcher misses (training FAQ?).
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-14 – Course structured data matches the 4 visible courses
- Research: searched "mobile repairing course Assandh Karnal Panipat chip level training institute". Results are IndiaMART seller pages, coursetakers.com, careers360, MRMTTI and Delhi institutes; no Karnal/Assandh training website ranks. Also checked whether training.html could get Hindi/Punjabi text like booking.html: the page has no language switcher at all, so that would be a big change (and touches the switcher) — skipped.
- Change: training.html had one Course JSON-LD named "Advanced Chip-Level Mobile Repair & Microsoldering Course" that does not match any course name on the page (and mentioned BGA in its description). Replaced it with an ItemList of the 4 courses shown on the page (Basic Mobile Repairing, Android Mobile Repairing, iPhone Hardware Repair, Advanced Chip-Level Repair), names and descriptions copied word-for-word from the visible course cards, provider = the same LocalBusiness (@id #business, url now the home page). No fees, duration or dates added (not on the site). FAQPage and Breadcrumb JSON-LD and all visible content untouched.
- Sitemap lastmod not touched (no visible content change).
- Why: structured data should match visible content; now Google sees each real course by its real name, which helps "android mobile repairing course" / "iPhone repair course" searches connect to this page.

### Ideas for future days
- Similar visible model line on iphone-repair.html only if the site already names iPhone models somewhere.
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi for training.html would need a switcher there — ask owner first; it is a bigger job.
- Owner action idea: IndiaMART/Justdial listing for the training with the same name-address-phone (IndiaMART course listings show up for course searches).
