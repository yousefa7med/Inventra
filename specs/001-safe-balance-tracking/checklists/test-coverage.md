# Test Scenario Coverage Checklist: Safe Balance Tracking

**Purpose**: Validate that quickstart.md validation scenarios comprehensively cover all user stories, edge cases, error flows, and integration points — ensuring test scenarios are well-defined, measurable, and traceable to requirements
**Created**: 2026-07-07
**Feature**: [spec.md](spec.md)
**Plan**: [plan.md](plan.md)
**Quickstart**: [quickstart.md](quickstart.md)
**Contracts**: [contracts/safe_cubit_interface.md](contracts/safe_cubit_interface.md)
**Data Model**: [data-model.md](data-model.md)

---

## Scenario Class Coverage (Primary / Alternate / Exception / Recovery / Non-Functional)

- [ ] CHK001: Are validation scenarios defined for ALL 5 user stories (US1–US5) with explicit Given/When/Then structure? [Coverage, Spec §User Stories]
- [ ] CHK002: Are alternate flow scenarios defined (e.g., cancel during expense add, cancel during balance adjust)? [Coverage, Spec §US2-AS4, US4-AS3]
- [ ] CHK003: Are exception/error flow scenarios defined for each user story (validation failures, database errors, reference not found)? [Coverage, Spec §Contracts Error Cases]
- [ ] CHK004: Are recovery flow scenarios defined (e.g., app restart persistence, filter reset after restart)? [Coverage, Spec §US9, Edge Cases]
- [ ] CHK005: Are non-functional scenarios defined for each measurable success criterion (SC-001 through SC-010)? [Coverage, Spec §Success Criteria]

---

## User Story 1 – View Safe Balance & Expense History (P1)

- [ ] CHK006: Does Scenario 1 (Initial State) verify the zero-state balance AND empty list with specific expected values? [Completeness, Spec §US1-AS1, Quickstart §Scenario 1]
- [ ] CHK007: Does Scenario 3 (Multiple Expenses) verify balance calculation matches FR-003 formula (initial + income - expenses - returns + adjustments)? [Completeness, Spec §FR-003, Quickstart §Scenario 3]
- [ ] CHK008: Is there a scenario verifying expense list ordering (newest-first per Edge Cases)? [Coverage, Spec §Edge Cases, Gap in Quickstart]
- [ ] CHK009: Is there a scenario verifying the balance display shows negative values with correct RTL currency format (FR-021)? [Completeness, Spec §FR-021, Quickstart §Scenario 8]
- [ ] CHK010: Is there a scenario verifying audit trail is accessible/visible to user (if required)? [Gap, Spec §FR-012 implies audit visibility]

---

## User Story 2 – Add New Expense (P1)

- [ ] CHK011: Does Scenario 2 verify the complete happy path: FAB tap → form → save → balance decrease → list update → audit entry? [Completeness, Spec §US2-AS2, Quickstart §Scenario 2]
- [ ] CHK012: Does Scenario 11 cover ALL validation error cases: value=0, value=negative, value=non-numeric, note=empty? [Completeness, Spec §FR-006, Quickstart §Scenario 11]
- [ ] CHK013: Is there a scenario verifying date is auto-captured as current date (not user-entered)? [Completeness, Spec §FR-005, Gap in Quickstart]
- [ ] CHK014: Is there a scenario verifying duplicate expense confirmation (same value+note within threshold)? [Coverage, Spec §Edge Cases, Gap in Quickstart]
- [ ] CHK015: Is there a scenario verifying expense immutability (no edit/delete UI, corrections via balance adjust only)? [Completeness, Spec §FR-007a, Gap in Quickstart]

---

## User Story 3 – Filter & Search Expenses (P2)

- [ ] CHK016: Does Scenario 4 verify date range filter works with explicit from/to dates and shows correct subset? [Completeness, Spec §FR-008, Quickstart §Scenario 4]
- [ ] CHK017: Does Scenario 5 verify case-insensitive partial match search on Arabic notes? [Completeness, Spec §FR-009, Quickstart §Scenario 5]
- [ ] CHK018: Does Scenario 6 verify combined filter + search (AND logic) works correctly? [Completeness, Spec §FR-010, Quickstart §Scenario 6]
- [ ] CHK019: Is there a scenario verifying empty filter results state (date range with no matches)? [Coverage, Gap in Quickstart]
- [ ] CHK020: Is there a scenario verifying filter clearing restores full list (FR-008a)? [Coverage, Spec §FR-008a, Quickstart §Scenario 6 implies but not explicit]
- [ ] CHK021: Is there a scenario verifying filter persistence within session but reset on app restart (FR-008a, Edge Cases)? [Completeness, Spec §FR-008a, Gap in Quickstart]

---

## User Story 4 – Manual Balance Adjustment (P2)

- [ ] CHK022: Does Scenario 7 verify the replace (set-to-total) behavior with delta audit entry? [Completeness, Spec §US4-AS2, Quickstart §Scenario 7]
- [ ] CHK023: Is there a scenario verifying cancel during adjustment leaves balance unchanged? [Coverage, Spec §US4-AS3, Gap in Quickstart]
- [ ] CHK024: Is there a scenario verifying manual adjustment with optional note saves note to audit entry? [Completeness, Spec §FR-012, Quickstart §Scenario 7 includes note]
- [ ] CHK025: Is there a scenario verifying adjustment validation (invalid numeric input, bounds)? [Coverage, Spec §Contracts Error Cases, Quickstart §Scenario 11 partial]

---

## User Story 5 – Invoice/Return Integration (P3 Future)

- [ ] CHK026: Does Scenario 10 verify all 3 integration types (buyInvoice, sellInvoice, returnReceipt) with correct signed amounts? [Completeness, Spec §US5-AS1–3, Quickstart §Scenario 10]
- [ ] CHK027: Is there a scenario verifying integration calls are transactional (balance + audit atomic)? [Coverage, Spec §FR-013a, Gap in Quickstart]
- [ ] CHK028: Is there a scenario verifying referenceId links to correct source entity type per integration type? [Coverage, Spec §FR-013a, Gap in Quickstart]
- [ ] CHK029: Is there a scenario verifying error handling when SafeCubit is not registered (GetIt failure)? [Gap, Spec §FR-013]

---

## Edge Cases & Boundary Conditions

- [ ] CHK030: Are scenarios defined for negative balance visual highlight (red color per theme)? [Coverage, Spec §Edge Cases, Quickstart §Scenario 8]
- [ ] CHK031: Are scenarios defined for maximum value boundary (999,999,999 per Edge Cases)? [Coverage, Spec §Edge Cases, Gap in Quickstart]
- [ ] CHK032: Are scenarios defined for concurrent modification (last-write-wins for manual adjust)? [Coverage, Spec §Edge Cases, Gap in Quickstart]
- [ ] CHK033: Are scenarios defined for date filtering ignoring time component (calendar date only)? [Coverage, Spec §Assumptions, Gap in Quickstart]
- [ ] CHK034: Are scenarios defined for Arabic text search with diacritics/normalization? [Coverage, Spec §FR-009, Gap in Quickstart]

---

## Acceptance Criteria Measurability & Traceability

- [ ] CHK035: Does each scenario have explicit, measurable expected outcomes (not "verify works")? [Measurability, Quickstart §All Scenarios]
- [ ] CHK036: Does each scenario trace to specific FR/US/SC identifiers from spec.md? [Traceability, Quickstart §All Scenarios]
- [ ] CHK037: Are performance targets (SC-001 to SC-004) tested with specific thresholds (≤1s, ≤2s, ≤500ms)? [Measurability, Spec §SC-001–004, Quickstart §Scenario 13]
- [ ] CHK038: Are RTL compliance checks (SC-008) specific and verifiable (not just "RTL works")? [Measurability, Spec §SC-008, Quickstart §Scenario 12]
- [ ] CHK039: Are test coverage targets (SC-009) defined with specific layer percentages (90% cubit, 80% views)? [Measurability, Spec §SC-009, Quickstart §Definition of Done]

---

## Test Data & Environment Requirements

- [ ] CHK040: Are test data setup requirements documented (e.g., "expenses across multiple days" for filter test)? [Completeness, Quickstart §Scenario 4 Setup]
- [ ] CHK041: Are device/emulator requirements specified (mid-range Android for performance tests)? [Completeness, Spec §Performance Goals, Quickstart §Scenario 13]
- [ ] CHK042: Are database reset/cleanup steps defined between scenarios? [Coverage, Gap in Quickstart]
- [ ] CHK043: Are locale/RTL test environment requirements specified (Arabic locale forced)? [Coverage, Constitution §III, Gap in Quickstart]

---

## Integration & Contract Test Scenarios

- [ ] CHK044: Are contract test scenarios defined for SafeCubitInterface (balanceStream, expensesStream, adjustBalanceForTransaction)? [Coverage, Spec §Contracts, Gap in Quickstart]
- [ ] CHK045: Are mock/stub requirements documented for integration testing with future features (BuyInvoice, SellInvoice, ReturnReceipt)? [Coverage, Spec §FR-013, Gap in Quickstart]
- [ ] CHK046: Are Result<T> error code scenarios tested (validationError, notFound, databaseError, unknown)? [Coverage, Spec §Contracts Error Cases, Quickstart §Scenario 11 partial]

---

## Regression & Maintenance Scenarios

- [ ] CHK047: Are scenarios defined for schema migration (ObjectBox model changes) verification? [Coverage, Spec §ObjectBox codegen, Gap in Quickstart]
- [ ] CHK048: Are scenarios defined for verifying zero warnings from `flutter analyze`? [Coverage, Spec §SC-010, Quickstart §Definition of Done]
- [ ] CHK049: Are scenarios defined for verifying CHANGELOG.md update on feature completion? [Coverage, Constitution §Quality Gates, Gap in Quickstart]
- [ ] CHK050: Are scenarios defined for verifying `build_runner` execution after model changes? [Coverage, Spec §ObjectBox codegen, Quickstart §Prerequisites]