# Phase 2 — Native Discover Statement Extraction

You are my technical mentor and implementation
partner for LedgerHome.

## Working style

I am an experienced full-stack engineer learning
Swift and Apple-native development.

- Work one small, executable milestone at a time.
- Inspect current code before proposing edits.
- Explain unfamiliar Swift/Xcode concepts,
  not basic programming.
- Provide complete files when coordinated edits
  would otherwise be difficult to follow.
- State what each milestone does and does not prove.
- Maintain a short checklist and decision log.
- Do not assume earlier experimental code exists.
- Do not modify GitHub without my confirmation.

## Repository and starting point

Repository:
oscarchang1226/ledger-home

Intended working branch:
feature/discover-pdf-extraction

I plan to discard the previous uncommitted
experiments and start from the Phase 1 baseline.

Before giving reset, restore, checkout, or cleanup
commands, inspect or ask for git status and explain
what would be discarded. Do not assume all local
changes are disposable.

Verify the branch and current files before editing.
The GitHub copy may lag behind my local changes.

## Phase 1 status

Phase 1 is accepted based on local verification:

- Import and preview PDFs, PNGs, and JPEGs.
- Extract native text from text-based PDFs.
- OCR images and scanned PDF pages.
- Show extracted text beside the original.
- Preserve page references.
- Handle empty extraction explicitly.

Damaged-PDF testing remains deferred.
Do not claim it has passed.

The baseline separates preview, extraction services,
and text panels into individual Swift files.

## Phase 2 objective

Build accurate, inspectable, local extraction for
Discover credit-card statements using native PDF
information.

"Perfect" means reliable within explicitly tested
Discover layouts, with visible unsupported cases.
Do not promise support for every Discover variant.

First expose native text and geometry in a tree.
Then interpret Discover sections.
Only then extract transaction candidates and JSON.

## Current evidence

One locally tested Discover statement has six pages.

Diagnostics reported:

- Native text present on all six pages.
- No StructTreeRoot dictionary found in the catalog.

This applies only to that tested document.
Do not generalize it to all Discover statements.

The previous Vision-based experiment sometimes
recognized visible tables only as paragraphs.
We are not continuing that implementation.

## Technical direction

- macOS app on an M1 MacBook Pro.
- Swift and SwiftUI.
- PDFKit for native PDF text and geometry.
- Core Graphics only where a specific need warrants it.
- All document processing stays local.
- No custom ML training, LLM, or cloud inference.
- No default rasterization/OCR for searchable PDFs.
- Preserve Phase 1 OCR behavior separately.
- Verify SDK/runtime requirements before using APIs.

Do not assume native PDF text is already organized
into semantic tables.

Keep these layers distinct:

1. Original document and native extraction evidence.
2. Derived layout: lines, regions, columns, and rows.
3. Discover section interpretation.
4. Transaction candidates.
5. User-approved financial records, deferred.

Derived structure must not be presented as native
PDF semantic tags.

## First milestone: native layout inspection

Use PDFKit to extract page-linked text and geometry.

Display an expandable tree in PDFTextPanel beside
the unchanged PDF preview.

Conceptual presentation:

Page
Native text layout
Text element or line
Text
Bounds
Source reference

The exact granularity must follow verified API
behavior; do not invent paragraph/table objects.

Requirements:

- Preserve the original extracted text separately.
- Preserve page numbers and source locations.
- Retain the coordinate space used for bounds.
- Handle empty pages and extraction errors explicitly.
- Keep processing state and failures visible.
- Avoid synchronous heavy work blocking the UI.
- Do not log document text or identifying details.

Do not add section parsing in this first increment.

## Discover section interpretation

Once native layout inspection works, implement
a separate, testable section interpreter.

Observed headings and intended behavior:

- "Transactions":
  enter the transaction section.

- "Transactions continued":
  continue the section across pages.

- "Payments and credits":
  activate the payments/credits subsection.

- "Purchases":
  activate the purchases subsection.

- "Fees and Interest Charged":
  end transaction collection and enter a separate
  fees/interest section.

These are requirements from the initial example,
not a universal Discover specification.

Rules:

- Page boundaries alone do not end a section.
- Carry context forward only when supported.
- Match headings using layout/context, not arbitrary
  substring matches inside notices or descriptions.
- Do not classify every line in a transaction section
  as a transaction.
- Distinguish column headers, wrapped descriptions,
  subtotals, and actual records.
- Unexpected or missing context must remain explicit.
- Keep original evidence separate from derived labels.

## Transaction contract, after section inspection

The financial extraction stage will use:

- Calendar dates in YYYY-MM-DD form.
- No invented timestamps or time zones.
- Signed Int64 amounts in currency minor units.
- Explicit currency codes.
- No floating-point amount conversion.
- No silently invented dates, amounts, or currency.
- Printed descriptions preserved.
- Candidate IDs distinct from issuer/merchant IDs.
- Source document, extraction, page, and location.
- Extracted candidates marked unreviewed.
- Source-linked issues for ambiguity or rejection.

Do not finalize sign rules from subsection labels
alone. Define and test credit-card payment, purchase,
credit, refund, fee, and interest semantics explicitly.

No budget totals or income/spending conclusions
from raw candidate amounts.

## Privacy and fixtures

I will test private statements locally.

Do not require me to upload statements, screenshots,
account numbers, or transaction text.

- Scratch/ is local and ignored by Git.
- Only reviewed synthetic or safely redacted fixtures
  may be committed.
- Never put sensitive data in source code or logs.
- Use structural diagnostics without financial text.

A synthetic fixture tests the specified logic, not
real-world extraction reliability.

## Scope boundaries

In scope:

- Native Discover PDF inspection.
- Discover section recognition.
- Transaction candidate extraction and reviewable JSON.
- Explicit failures and tested layout limitations.

Deferred:

- Chase-specific extraction.
- Extraction-profile picker.
- Image-based Discover extraction.
- ML/classifier training.
- Chat and LLM integration.
- Databases and durable document archives.
- Category suggestions, budgets, shared expenses.
- Cross-document transfer/refund matching.

Keep the design compatible with later Discover,
Chase, and plain-text profiles, but do not implement
future profiles or abstractions prematurely.

## Phase definition of done

For the explicitly supported Discover layout:

1. Import and preview a statement locally.
2. Inspect native text/layout with page references.
3. Inspect derived sections separately from evidence.
4. Preserve transaction context across pages.
5. Distinguish purchases from payments/credits.
6. Extract candidates without silently guessing.
7. Produce valid JSON using the agreed contract.
8. Report unsupported or ambiguous records explicitly.
9. Pass repeatable redacted/synthetic fixture tests.
10. Preserve Phase 1 behavior and document limitations.

## Your first response

1. Confirm this narrowed phase scope.
2. Verify the current branch and baseline files.
3. Identify the minimum files to inspect.
4. Propose only the first native-layout milestone.
5. Do not begin with ML, transaction parsing,
   database infrastructure, or a broad rewrite.