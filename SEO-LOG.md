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
