# Bugfix Requirements Document

## Introduction

A comprehensive audit of the `ignitia_server` FastAPI backend identified ten confirmed bugs
spanning deprecated Python APIs, performance regressions, calculation errors, data-filtering
omissions, dead/misleading code, and inconsistent seed data. Each issue is traceable to a
specific file and line range. All 31 existing tests pass before any fix; the fixes must not
break them.

The bugs are grouped into four concern areas:

- **Deprecations** (BUGs 1–2): `datetime.utcnow()` and the `httpx` package pin will break on
  future Python / dependency versions and already emit warnings.
- **Performance** (BUGs 3–4): Face-verification models are re-instantiated on every request.
- **Logic flaws** (BUGs 5–6, 8): Payroll overtime rate uses a hardcoded constant; the
  attendance summary ignores the date range when counting leave days; AIT is computed on gross
  rather than taxable income.
- **Code quality / data integrity** (BUGs 7, 9–10): A dead `used` flag in liveness challenge
  tracking is misleading; seed data and test fixtures omit a required-adjacent field.

---

## Bug Analysis

### Current Behavior (Defect)

<!-- BUG 1 — datetime.utcnow() -->
1.1 WHEN the server creates a JWT token or writes a timestamp to the database THEN the system
    calls `datetime.utcnow()` (deprecated since Python 3.12, scheduled for removal), emitting
    `DeprecationWarning` on every affected code path (`app/security.py:67-68`,
    `app/routers/login.py:102,139`, `app/models.py` column defaults for
    `AttendanceEditRequest.created_at` and `PasswordResetToken.created_at`).

1.2 WHEN PyJWT encodes the JWT payload with a naive `datetime` `exp` claim THEN the system
    triggers a `PyJWT` deprecation warning because the library expects timezone-aware datetimes
    for the `exp` field.

<!-- BUG 2 — httpx deprecation -->
1.3 WHEN the test suite runs against FastAPI's `TestClient` THEN the system raises
    `StarletteDeprecationWarning: Using httpx with starlette.testclient is deprecated; install
    httpx2 instead`, because `requirements.txt` pins `httpx>=0.27` (the old package) instead of
    the required `httpx2`.

<!-- BUG 3 — No model caching for YuNet / SFace -->
1.4 WHEN a check-in or check-out request that requires face verification is processed THEN the
    system calls `cv2.FaceDetectorYN_create` and `cv2.FaceRecognizerSF_create` on every
    invocation of `_yunet_detector()` and `_sface_recognizer()`, loading the models from disk
    each time (~100–200 ms per call) and re-triggering `cv::dnn` backend warnings.

<!-- BUG 4 — _sface_match inner embed re-creates detector -->
1.5 WHEN `_sface_match` is called to compare two face images THEN the system calls
    `_yunet_detector()` separately for each image inside the nested `embed()` closure, resulting
    in two independent model-load cycles per match even after BUG 3 is fixed if the cache is not
    shared with the inner call.

<!-- BUG 5 — Payroll hourly rate hardcoded 240 -->
1.6 WHEN the payslip is calculated for any month THEN the system computes the overtime hourly
    rate as `basic_salary / 240` regardless of the actual number of working hours in that month
    (`app/routers/payroll.py:91`), using an arbitrary constant (8 h × 30 d) that is inconsistent
    with the `absent_deduction` formula which divides by `days_of_month`.

<!-- BUG 6 — leave_days ignores date range -->
1.7 WHEN the attendance summary (`/Attendance/userAttendanceSummary`) is requested for a
    specific date range THEN the system counts all approved leave records for the employee across
    all time (`app/routers/attendance.py:287-294`), without applying the `startDate`/`endDate`
    filters that are applied to the attendance records, inflating the `leave_days` count for
    narrow date ranges.

<!-- BUG 7 — dead `used` flag in liveness challenge -->
1.8 WHEN `consume_liveness_challenge` pops a challenge id from `_challenges` THEN the system
    checks `entry["used"]` on the already-removed entry (`app/security.py:394-402`). Because
    the `used` flag is always `False` at time of consumption (it is never set to `True`
    anywhere), and the entry has already been removed by `.pop()`, the check is dead code that
    can never influence the result, misleading maintainers into believing replay protection
    depends on a flag that has no effect.

<!-- BUG 8 — AIT calculated on gross instead of taxable net -->
1.9 WHEN the payslip net pay is computed THEN the system calculates AIT (income tax) as 10% of
    gross salary (`ait = round(gross * 0.10, 2)`) before absent deductions and overtime are
    considered (`app/routers/payroll.py:98`), meaning employees with large absences are taxed on
    income they did not receive.

<!-- BUG 9 — seed.py missing joining_date -->
1.10 WHEN the database is seeded with `python seed.py` THEN the system creates both demo
     employees without a `joining_date` value (`seed.py`), even though the `Employee.joining_date`
     column has no `nullable=True` declaration and any code path that calls
     `emp.joining_date.isoformat()` without guarding for `None` would raise `AttributeError`.

<!-- BUG 10 — conftest.py missing joining_date -->
1.11 WHEN the test suite sets up the demo employees in `conftest.py` THEN the system creates
     both employees without a `joining_date` value (`tests/conftest.py:53-70`), leaving the test
     fixtures inconsistent with the production seed and masking any future regression where
     `joining_date` is accessed without a None guard.

---

### Expected Behavior (Correct)

<!-- BUG 1 fix -->
2.1 WHEN the server creates a JWT token or writes a timestamp THEN the system SHALL use
    `datetime.now(timezone.utc)` in place of `datetime.utcnow()` across all call sites
    (`app/security.py`, `app/routers/login.py`, `app/models.py` column defaults), producing no
    `DeprecationWarning`.

2.2 WHEN PyJWT encodes the JWT payload THEN the system SHALL supply a timezone-aware `exp`
    datetime (or strip `tzinfo` consistently) so that no PyJWT deprecation warning is emitted.

<!-- BUG 2 fix -->
2.3 WHEN the test suite is installed and run THEN the system SHALL reference `httpx2` (or a
    compatible `httpx` version supported by the installed FastAPI/Starlette) in
    `requirements.txt`, and no `StarletteDeprecationWarning` about `httpx` SHALL be raised.

<!-- BUG 3 fix -->
2.4 WHEN face verification is performed THEN the system SHALL load the YuNet detector and SFace
    recognizer from disk at most once per process lifetime (module-level cache via
    `functools.lru_cache` or a module-level singleton), so that subsequent check-in/check-out
    requests reuse the already-loaded models without disk I/O.

<!-- BUG 4 fix -->
2.5 WHEN `_sface_match` embeds two face images THEN the system SHALL reuse the same cached
    detector instance for both the reference and capture embedding calls, incurring zero
    additional model-load cost beyond what is already cached by BUG 3's fix.

<!-- BUG 5 fix -->
2.6 WHEN the payslip overtime hourly rate is calculated THEN the system SHALL use
    `(days_of_month - holidays) * 8` as the denominator (actual working hours in the month)
    instead of the hardcoded constant `240`, ensuring overtime pay is consistent with how
    `absent_deduction` is derived.

<!-- BUG 6 fix -->
2.7 WHEN the attendance summary is requested with a `startDate` and `endDate` THEN the system
    SHALL apply `UserLeave.start_date >= start` and `UserLeave.end_date <= end` filters to the
    leave query, returning only leave records that fall within the requested date range,
    consistent with the filter applied to attendance records and with the payroll endpoint.

<!-- BUG 7 fix -->
2.8 WHEN a liveness challenge is consumed THEN the system SHALL rely solely on the `_challenges`
    dict `.pop()` operation for single-use enforcement and SHALL NOT include a `"used"` flag in
    the challenge entry, removing the dead code and making the replay-prevention mechanism
    explicit and unambiguous.

<!-- BUG 8 fix -->
2.9 WHEN the payslip AIT (income tax) is calculated THEN the system SHALL compute AIT on the
    taxable base after absent deductions (`gross + ot_amount - absent_deduction`) or document
    the business rule explicitly if taxing gross is intentional, so that the formula is
    unambiguous and auditable.

<!-- BUG 9 fix -->
2.10 WHEN `seed.py` creates demo employees THEN the system SHALL populate `joining_date` for
     every seeded employee (e.g., `datetime(2024, 1, 1)`) so that the column invariant is
     satisfied and `employee_json` never receives a `None` joining_date from seed-created records.

<!-- BUG 10 fix -->
2.11 WHEN `conftest.py` creates test employees THEN the system SHALL populate `joining_date` for
     every fixture employee, keeping the test fixtures consistent with the production seed and
     ensuring test coverage is not invalidated by a missing field.

---

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a valid employee logs in with correct credentials THEN the system SHALL CONTINUE TO
    return a JWT token in the `message` field and an HTTP 200 response with `isSuccess: true`.

3.2 WHEN an employee submits an invalid password THEN the system SHALL CONTINUE TO return
    HTTP 401 with `isSuccess: false`.

3.3 WHEN a check-in request is submitted with valid geo-coordinates, a matching face image, and
    a valid liveness challenge THEN the system SHALL CONTINUE TO record the attendance and
    return `{"isSuccess": true, "message": "Check-in successful"}`.

3.4 WHEN a check-in request is submitted with coordinates outside the geo-fence THEN the system
    SHALL CONTINUE TO reject the request with the configured out-of-range message.

3.5 WHEN a check-in request is submitted with a non-matching face image THEN the system
    SHALL CONTINUE TO reject the request with the configured face-verification failure message.

3.6 WHEN a liveness challenge id is used a second time THEN the system SHALL CONTINUE TO reject
    the request as an invalid or expired challenge.

3.7 WHEN an expired liveness challenge id is used THEN the system SHALL CONTINUE TO reject
    the request as invalid or expired.

3.8 WHEN the payslip endpoint is called with a valid employee and month THEN the system SHALL
    CONTINUE TO return `isSuccess: true` and a `data` object with all expected payslip fields
    (`employee_id`, `name`, `days_of_month`, `present_days`, `absent_days`, `leave_days`,
    `gross_salary`, `net_pay`, `ot_amount`, etc.).

3.9 WHEN the attendance summary endpoint is called with a date range containing no leave
    records THEN the system SHALL CONTINUE TO return `leave_days: 0`.

3.10 WHEN the attendance summary endpoint is called without a start date THEN the system
     SHALL CONTINUE TO return a summary based on records up to and including the end date.

3.11 WHEN the password reset flow is used with a valid, unexpired, single-use token THEN the
     system SHALL CONTINUE TO reset the employee's password and mark the token as used.

3.12 WHEN all 31 existing automated tests are executed THEN the system SHALL CONTINUE TO pass
     without any test failures.

---

## Bug Condition Pseudocode

### BUG 1 / BUG 2 — Deprecation conditions

```pascal
FUNCTION isBugCondition_Deprecation(X)
  INPUT: X of type CodeCallSite
  OUTPUT: boolean
  RETURN X.uses_datetime_utcnow OR X.requires_old_httpx
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_Deprecation(X) DO
  result ← updatedCallSite(X)
  ASSERT no_deprecation_warning(result)
END FOR

// Preservation Checking
FOR ALL X WHERE NOT isBugCondition_Deprecation(X) DO
  ASSERT F(X) = F'(X)
END FOR
```

### BUG 3 / BUG 4 — Model caching condition

```pascal
FUNCTION isBugCondition_ModelLoad(X)
  INPUT: X of type FaceVerificationRequest
  OUTPUT: boolean
  RETURN cv2_available AND (detector_not_cached OR recognizer_not_cached)
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_ModelLoad(X) DO
  result ← verifyFace'(X)
  ASSERT model_load_count(result) <= 1_per_process
END FOR

// Preservation Checking
FOR ALL X WHERE NOT isBugCondition_ModelLoad(X) DO
  ASSERT F(X) = F'(X)  // same verification pass/fail outcome
END FOR
```

### BUG 5 — Hourly rate condition

```pascal
FUNCTION isBugCondition_HourlyRate(X)
  INPUT: X of type PayslipRequest
  OUTPUT: boolean
  RETURN (days_of_month(X) - holidays(X)) * 8 <> 240
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_HourlyRate(X) DO
  result ← getPayslip'(X)
  ASSERT result.ot_amount = (ot_minutes / 60) * (basic / ((days_of_month - holidays) * 8))
END FOR

// Preservation Checking
FOR ALL X WHERE NOT isBugCondition_HourlyRate(X) DO
  ASSERT F(X).ot_amount = F'(X).ot_amount
END FOR
```

### BUG 6 — Leave days date-filter condition

```pascal
FUNCTION isBugCondition_LeaveFilter(X)
  INPUT: X of type AttendanceSummaryRequest
  OUTPUT: boolean
  RETURN X.startDate <> null AND employee_has_leave_outside_range(X)
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_LeaveFilter(X) DO
  result ← userAttendanceSummary'(X)
  ASSERT result.leave_days = count_leaves_within_range(X)
END FOR

// Preservation Checking
FOR ALL X WHERE NOT isBugCondition_LeaveFilter(X) DO
  ASSERT F(X).leave_days = F'(X).leave_days
END FOR
```

### BUG 7 — Dead liveness `used` flag condition

```pascal
FUNCTION isBugCondition_DeadFlag(X)
  INPUT: X of type LivenessChallengeEntry
  OUTPUT: boolean
  RETURN "used" IN X.fields
END FUNCTION

// Fix Checking
FOR ALL X WHERE isBugCondition_DeadFlag(X) DO
  entry ← issueChallenge'()
  ASSERT "used" NOT IN entry
  consumed ← consumeChallenge'(entry.id)
  ASSERT consumed = true
  replay ← consumeChallenge'(entry.id)
  ASSERT replay = false  // pop already removed it
END FOR
```
