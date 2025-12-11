# Test Plan: [Tên Project/Module]

**Project**: [Tên project]  
**Version/Release**: [v1.0, Sprint 3, etc.]  
**Created**: [YYYY-MM-DD]  
**Owner**: [Tên người chịu trách nhiệm testing]  
**Status**: [Draft / In Review / Approved / In Progress / Completed]

---

## 1. Mục tiêu kiểm thử

**Mô tả ngắn gọn mục đích của test plan này**:

- Đảm bảo hệ thống mới có behavior tương đương với hệ thống cũ (parity).
- Phát hiện regression bugs trước khi deploy production.
- Verify performance, security, scalability đáp ứng yêu cầu.

**Success criteria**:

- [ ] Test coverage ≥ 80% (unit + integration).
- [ ] Không có P0/P1 bugs chưa fix.
- [ ] Performance đạt baseline (response time ≤ Xms, throughput ≥ Y req/s).
- [ ] Security scan pass (không có critical/high vulnerabilities).

---

## 2. Scope (Phạm vi kiểm thử)

### 2.1. In Scope

Liệt kê rõ các module/tính năng/API được test:

- [ ] Module A: Authentication & Authorization
- [ ] Module B: Data processing pipeline
- [ ] Module C: REST API endpoints
- [ ] Performance testing: Load test với 1000 concurrent users
- [ ] Security testing: OWASP Top 10

### 2.2. Out of Scope

Những gì **không** được cover trong test plan này (để tránh hiểu nhầm):

- [ ] UI/UX testing (sẽ có test plan riêng).
- [ ] Third-party integrations (giả định stable).
- [ ] Legacy system (chỉ test hệ thống mới).

---

## 3. Test Strategy (Chiến lược kiểm thử)

### 3.1. Test Levels

Áp dụng Testing Pyramid (chi tiết: `guides/3-testing-strategy.md`):

| Level                 | Tool/Framework                  | Coverage Target        | Owner         |
| --------------------- | ------------------------------- | ---------------------- | ------------- |
| **Unit Tests**        | [pytest, JUnit, Jest, etc.]     | ≥70% line coverage     | Dev team      |
| **Integration Tests** | [pytest, Testcontainers, etc.]  | Key workflows          | Dev team      |
| **Contract Tests**    | [Pact, Spring Cloud Contract]   | All external APIs      | Dev + QA      |
| **E2E Tests**         | [Playwright, Cypress, Selenium] | Happy paths            | QA team       |
| **Performance Tests** | [JMeter, k6, Locust]            | Baseline + stress      | QA/DevOps     |
| **Security Tests**    | [OWASP ZAP, SonarQube, Snyk]    | Top 10 vulnerabilities | Security team |

### 3.2. Test Approach

**Test-Driven Migration (TDM)**:

1. Viết test cho behavior hiện tại (characterization tests).
2. Migrate code sang hệ thống mới.
3. Chạy lại test → đảm bảo behavior không thay đổi.

**Parallel Run** (nếu có thể):

- Chạy cả hệ thống cũ + hệ thống mới cùng lúc.
- So sánh output/response → tìm discrepancies.

---

## 4. Test Environment (Môi trường kiểm thử)

| Environment     | Purpose                                  | Data                       | Access      |
| --------------- | ---------------------------------------- | -------------------------- | ----------- |
| **Dev**         | Developer testing, CI/CD                 | Synthetic data             | All devs    |
| **Staging**     | Integration testing, pre-prod validation | Anonymized prod clone      | Dev + QA    |
| **Performance** | Load/stress testing                      | Simulated high-volume data | QA + DevOps |
| **Production**  | Canary/smoke tests only                  | Real prod data             | Ops only    |

**Infrastructure**:

- OS: [Linux/Windows/macOS]
- Runtime: [Python 3.11, Node.js 20, Java 17, etc.]
- Database: [PostgreSQL 15, MySQL 8, etc.]
- Message queue: [RabbitMQ, Kafka, etc.]
- External dependencies: [List third-party services]

---

## 5. Test Cases / Scenarios (Danh sách test)

### 5.1. Functional Tests

| ID     | Test Case                         | Priority | Pre-condition       | Steps                                                   | Expected Result      | Status      |
| ------ | --------------------------------- | -------- | ------------------- | ------------------------------------------------------- | -------------------- | ----------- |
| TC-001 | User login với credentials hợp lệ | P0       | User account exists | 1. POST /api/login<br>2. Input: valid username/password | 200 OK, token trả về | Not Started |
| TC-002 | User login với password sai       | P1       | User account exists | 1. POST /api/login<br>2. Input: invalid password        | 401 Unauthorized     | Not Started |
| TC-003 | ...                               | ...      | ...                 | ...                                                     | ...                  | ...         |

### 5.2. Non-Functional Tests

| ID     | Test Type   | Metric              | Target                  | Test Tool | Status      |
| ------ | ----------- | ------------------- | ----------------------- | --------- | ----------- |
| NF-001 | Performance | Response time (p95) | ≤200ms                  | JMeter    | Not Started |
| NF-002 | Load        | Concurrent users    | 1000 users, no error    | k6        | Not Started |
| NF-003 | Security    | OWASP Top 10        | No critical/high issues | OWASP ZAP | Not Started |
| NF-004 | ...         | ...                 | ...                     | ...       | ...         |

---

## 6. Entry & Exit Criteria

### 6.1. Entry Criteria (Điều kiện để bắt đầu testing)

- [ ] Code complete, deployed to test environment.
- [ ] Unit tests pass (≥70% coverage).
- [ ] Test data prepared.
- [ ] Test environment stable (uptime ≥99%).

### 6.2. Exit Criteria (Điều kiện để kết thúc testing)

- [ ] Tất cả test cases executed (hoặc skipped với lý do rõ ràng).
- [ ] Test coverage ≥80%.
- [ ] Không có P0/P1 bugs open.
- [ ] Performance targets đạt.
- [ ] Test report approved bởi stakeholders.

---

## 7. Risks & Mitigation (Rủi ro & giải pháp)

| Risk                                     | Impact | Likelihood | Mitigation                                                  |
| ---------------------------------------- | ------ | ---------- | ----------------------------------------------------------- |
| Test environment không ổn định           | High   | Medium     | Dự phòng environment backup, monitor uptime                 |
| Thiếu test data cho edge cases           | Medium | High       | Sinh synthetic data, anonymize prod data                    |
| Performance test chạy lâu, block release | High   | Medium     | Chạy song song, tối ưu test suite, sử dụng distributed load |
| Security bugs phát hiện muộn             | High   | Low        | Integrate SAST/DAST vào CI/CD pipeline                      |

---

## 8. Schedule & Resources (Lịch trình & nguồn lực)

| Activity                     | Duration | Owner       | Dependencies             |
| ---------------------------- | -------- | ----------- | ------------------------ |
| Test planning                | 2 days   | QA Lead     | Plan + Design approved   |
| Test case writing            | 3 days   | QA team     | Test plan approved       |
| Test execution (functional)  | 5 days   | QA team     | Code deployed to staging |
| Test execution (performance) | 2 days   | DevOps + QA | Functional tests pass    |
| Bug fixing & retesting       | 3 days   | Dev + QA    | Bugs reported            |
| Test report & sign-off       | 1 day    | QA Lead     | All tests completed      |

**Total estimated**: [X] days

**Team**:

- QA Lead: [Tên]
- QA Engineers: [Tên 1, Tên 2]
- DevOps: [Tên]
- Developers (for bug fixes): [Tên]

---

## 9. Deliverables (Kết quả đầu ra)

- [ ] Test plan document (file này).
- [ ] Test cases (spreadsheet hoặc test management tool).
- [ ] Test execution report (pass/fail summary, coverage, bugs found).
- [ ] Bug reports (filed in Jira/GitHub Issues).
- [ ] Performance benchmarks (response time, throughput charts).
- [ ] Security scan report (vulnerability list, remediation status).

---

## 10. Approval & Sign-off

| Role          | Name  | Signature  | Date     |
| ------------- | ----- | ---------- | -------- |
| QA Lead       | [Tên] | ****\_**** | \_\_\_\_ |
| Dev Lead      | [Tên] | ****\_**** | \_\_\_\_ |
| Product Owner | [Tên] | ****\_**** | \_\_\_\_ |

---

## References

- **Testing Strategy Guide**: `guides/3-testing-strategy.md`
- **Migration Process**: `guides/1-migration-process.md`
- **Code Patterns**: `guides/2-code-migration-patterns.md`
- **Checklists**: `checklists/3-code-review-checklist.md`

---

**Notes**:

- Test plan này là living document, cập nhật khi có thay đổi scope/requirements.
- Mọi thay đổi lớn cần approval từ QA Lead + Product Owner.
