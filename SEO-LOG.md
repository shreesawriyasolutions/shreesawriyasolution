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

## 2026-11-15 – Local meta description on home page
- Research: searched "mobile phone repair Jind Safidon Assandh shop". Results are explurger/ueni/Google Sites/IndiaMART listings and a Samsung service centre page; no local repair website competes. Checked all 5 public pages: every <img> has alt text and size, internal links between pages are in place, so on-page basics are done.
- Change: index.html meta description still read "…in Assandh, Haryana. Explore phone repair, accessories…" (no Karnal, no address, no free diagnosis, no hours). Rewrote it from facts already visible on the page: "Mobile repair shop at Salwan Chowk, Assandh (Karnal): iPhone, Android & chip-level repair, free diagnosis, accessories, repair training. Open daily 9 AM–8 PM." (158 chars). og:description/twitter:description updated the same way (Assandh, Haryana → Salwan Chowk, Assandh, Karnal; free phone diagnosis added). Title, visible text, JSON-LD, switcher, WhatsApp and reviews untouched.
- Sitemap lastmod not touched (no visible content change).
- Why: the home page is the page Google shows for brand and "mobile repair Assandh" searches; the snippet now matches the subpages (which already name Karnal) and gives the searcher the address, free diagnosis and daily hours, which should lift clicks.

### Ideas for future days
- postalCode in address JSON-LD (verify PIN with owner).
- Hindi/Punjabi for training.html would need a switcher there — ask owner first; it is a bigger job.
- Home "About Us" lede "Trusted since years in Assandh" is awkward English, but it is visible text with translations; only fix with owner OK.
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-16 – Home page services in structured data
- Research: searched "mobile repair shop Assandh Karnal" and "mobile repairing near Assandh Gharaunda Nissing Karnal shop". Same picture: Flipkart city pages (Karnal, Panipat), dnb.com/explurger/ueni/Google Sites/bino.bot listings and unrelated Assandh vehicle service centres. No local repair website competes.
- Checked the gallery photos as a possible LocalBusiness "image": they are training/certificate photos at other institutes, not the shop, so NOT used. A real shop-front/counter photo would be a good addition later.
- Change: index.html LocalBusiness JSON-LD now has a "hasOfferCatalog" listing the 7 services shown in the visible "Our Services" section (iPhone Repair, Android Repair, Chip-Level Repair, Second-Hand Smartphones, Accessories, Chip-Level Training, Doorstep Delivery). Names and descriptions were generated straight from the visible data-en text (word-for-word); url added for the three that link to their own page. No price fields added. LocalBusiness description "Assandh, Haryana" → "Salwan Chowk, Assandh, Karnal (Haryana)". Visible content, switcher, WhatsApp, reviews untouched; sitemap lastmod not touched.
- Why: the main business entity (@id #business) now tells Google all its services in one place and links to the service pages, so searches like "second hand phone Assandh" or "chip level repair Karnal" connect to the business.
- Note: the home page "Get Directions" button uses maps.app.goo.gl/BjYoa9JeiDTkPhtt6 while JSON-LD uses maps.app.goo.gl/r9f8K1coYFswbRP39. Could not open Google Maps from this run to check both go to the same pin; verify with the owner before changing anything.

### Ideas for future days
- Shop photo (front/counter, 16:10, <300 KB) from the owner → use as LocalBusiness image + og:image.
- Confirm the two Google Maps links point to the same place.
- postalCode in address JSON-LD (verify PIN with owner).
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-17 – Local meta descriptions on the iPhone and Android repair pages
- Research: searched "iPhone screen repair Karnal Assandh shop". Results are Flipkart city pages (Karnal, Panipat), a Cashify store in Karnal, bino.bot/ueni/Google Sites listings and out-of-area shops; no local repair website competes.
- Change: iphone-repair.html and android-repair.html were the last public pages whose meta description had no Karnal, no Salwan Chowk and no "free diagnosis" (iPhone one said "Assandh, Haryana… Contact us to discuss"). Rewrote meta description + og/twitter description on both from facts already visible on each page (fault categories shown in the diagnosis grid, brand list, address in footer, "Book your free diagnosis" CTA). Lengths 152/160 chars. Title, visible text, JSON-LD, switcher, WhatsApp untouched; sitemap lastmod not touched.
- Why: all 5 public pages now have snippets naming Salwan Chowk, Assandh, Karnal and the free diagnosis, so "iPhone repair Karnal" / "Samsung repair Assandh" searchers see the place and a reason to click.

### Ideas for future days
- Shop photo (front/counter, 16:10, <300 KB) from the owner → LocalBusiness image + og:image.
- Confirm the two Google Maps links point to the same place.
- postalCode in address JSON-LD (verify PIN with owner).
- On-page basics are now largely complete; future days may often be "no change" unless the owner sends photos/facts.
- Owner action idea: Justdial/IndiaMART listing with the same name-address-phone.

## 2026-11-18 – One business URL in structured data on all pages
- Research: searched "mobile repair Assandh Karnal shop". Same picture as before: Flipkart city pages (Karnal, Panipat), dnb.com/explurger/ueni/Google Sites/bino.bot listings; no local repair website competes.
- Found: iphone-repair.html, android-repair.html and booking.html each declare the same LocalBusiness (@id #business) as index.html, but gave it a different "url" (the subpage itself) and said "Assandh, Haryana" without Karnal/Salwan Chowk. One business with 4 different URLs is a mixed signal.
- Change: on those 3 pages the LocalBusiness "url" is now the home page (same as index.html and training.html), and the JSON-LD description location reads "Salwan Chowk, Assandh, Karnal (Haryana)", matching index.html and the footer address. Service JSON-LD, visible text, switcher, form, WhatsApp untouched. Sitemap lastmod not touched (no visible change).
- Why: Google now sees one consistent business entity (same name, address, phone, URL) across the site, which supports the Google Business Profile match for local searches.

### Ideas for future days
- Shop photo (front/counter, 16:10, <300 KB) from the owner → LocalBusiness image + og:image.
- Confirm the two Google Maps links point to the same place.
- postalCode in address JSON-LD (verify PIN with owner).
- Home "About" text and the hero chip say "Assandh, Haryana" (visible, translated) — only change with owner OK.
- On-page basics are done; many future days should be "no change".

## 2026-11-19 – Smaller owner photo on the home page (page speed)
- Research: searched "mobile repair training institute Karnal Panipat Kaithal chip level course". Results are IndiaMART category/seller pages, coursetakers.com, careers360, MRMTTI and out-of-state institutes; still no Karnal/Assandh training website competing. On-page text/structured data is done (see earlier entries), so today went to speed.
- Found: the new "About Me" photo (owner.jpeg, added 2026-11-18) was 886×1132 px and 187 KB, but it is shown at most 340 px wide (CSS max-width) on index.html and 130 px round on card.html. It was the heaviest image on any public page.
- Change: re-saved owner.jpeg at 680×869 px (2× the 340 px display width, same aspect ratio as the width/height attributes 600×767), progressive JPEG quality 84 → 50 KB (−73%). Checked visually: sharp, same crop. No HTML change; alt text, lazy loading, switcher, WhatsApp, reviews untouched. Sitemap lastmod not touched.
- Why: smaller page weight on mobile data helps Core Web Vitals / mobile speed, which Google uses for local mobile results.

### Ideas for future days
- Shop photo (front/counter, 16:10, <300 KB) from the owner → LocalBusiness image + og:image.
- Owner photo could later go into JSON-LD as founder (Person "Ankush") — visible on the page; small, safe structured-data add.
- Confirm the two Google Maps links point to the same place.
- postalCode in address JSON-LD (verify PIN with owner).
- Owner action idea: IndiaMART listing for the training (IndiaMART dominates course searches) with the same name-address-phone.

## 2026-11-20 – Founder (Ankush) in home page structured data
- Research: searched "mobile repair Assandh Salwan Chowk". Results are IndiaMART seller pages, Flipkart city pages (Panipat, Chandigarh), Cashify, ueni/Google Sites/github.io shop sites from other towns; still no local Assandh repair website competing.
- Change: index.html LocalBusiness JSON-LD (@id #business) now has a "founder" Person: name "Ankush" (owner photo alt text + card.html "FOUNDER & EXPERT TECHNICIAN"), jobTitle "Professional Mobile Repair Technician" (visible About Me heading), image owner.jpeg, knowsAbout = the six skills listed word-for-word in the visible About Me text. No years/certificates/awards added to JSON-LD. Visible content, switcher, WhatsApp, reviews untouched; sitemap lastmod not touched.
- Why: ties the real expert to the business entity (E-E-A-T), and helps searches for "Ankush mobile repair Assandh" connect to the site and the Google Business Profile.

### Ideas for future days
- Shop photo (front/counter, 16:10, <300 KB) from the owner → LocalBusiness image + og:image.
- Confirm the two Google Maps links point to the same place.
- postalCode in address JSON-LD (verify PIN with owner).
- Structured data and on-page basics are now done on all 5 public pages; expect mostly "no change" days unless the owner sends new photos/facts.
- Owner action idea: IndiaMART listing for the training with the same name-address-phone.
