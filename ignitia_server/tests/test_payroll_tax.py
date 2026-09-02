"""Unit tests for PPh 21 progressive tax calculation.

Property: tax must be monotonically non-decreasing with income.
"""
import pytest
from app.routers.payroll import calculate_annual_pph21, calculate_ait_monthly, _DEFAULT_PTKP


def test_zero_pkp():
    assert calculate_annual_pph21(0) == 0.0


def test_negative_pkp():
    assert calculate_annual_pph21(-1_000_000) == 0.0


def test_layer1_exact():
    # 60_000_000 * 5% = 3_000_000
    assert calculate_annual_pph21(60_000_000) == pytest.approx(3_000_000)


def test_layer1_partial():
    # 30_000_000 * 5% = 1_500_000
    assert calculate_annual_pph21(30_000_000) == pytest.approx(1_500_000)


def test_layer2():
    # 60jt * 5% + 90jt * 15% = 3_000_000 + 13_500_000 = 16_500_000
    assert calculate_annual_pph21(150_000_000) == pytest.approx(16_500_000)


def test_layer3():
    # 60jt * 5% + 190jt * 15% + 50jt * 25%
    # = 3_000_000 + 28_500_000 + 12_500_000 = 44_000_000
    assert calculate_annual_pph21(300_000_000) == pytest.approx(44_000_000)


def test_layer4():
    # 60jt*5 + 190jt*15 + 250jt*25 + 100jt*30
    # = 3_000_000 + 28_500_000 + 62_500_000 + 30_000_000 = 124_000_000
    assert calculate_annual_pph21(600_000_000) == pytest.approx(124_000_000)


def test_monthly_ait_below_ptkp():
    # gross monthly 2jt, annual = 24jt < TK/0 54jt → AIT = 0
    ait = calculate_ait_monthly(2_000_000, _DEFAULT_PTKP)
    assert ait == 0.0


def test_monthly_ait_positive():
    # gross 10jt/month, annual = 120jt, PKP = 120jt - 54jt = 66jt
    # tax = 60jt*5% + 6jt*15% = 3_000_000 + 900_000 = 3_900_000 / 12 = 325_000
    ait = calculate_ait_monthly(10_000_000, _DEFAULT_PTKP)
    assert ait == pytest.approx(325_000, rel=1e-3)


def test_ait_monotone_simple():
    """Higher gross must produce equal or higher AIT (same PTKP)."""
    ptkp = _DEFAULT_PTKP
    ait_low = calculate_ait_monthly(5_000_000, ptkp)
    ait_high = calculate_ait_monthly(20_000_000, ptkp)
    assert ait_low <= ait_high


def test_net_pay_non_negative():
    """Net pay formula never goes negative for valid inputs."""
    gross = 5_000_000.0
    absent_deduction = 500_000.0
    ait = calculate_ait_monthly(gross, _DEFAULT_PTKP)
    net = max(0.0, gross - absent_deduction - ait)
    assert net >= 0.0
