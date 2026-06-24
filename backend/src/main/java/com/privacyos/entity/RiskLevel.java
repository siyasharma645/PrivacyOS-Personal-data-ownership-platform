package com.privacyos.entity;
public enum RiskLevel {
    LOW, MEDIUM, HIGH, CRITICAL;
    public static RiskLevel fromScore(int s) {
        if (s >= 80) return LOW; if (s >= 60) return MEDIUM; if (s >= 40) return HIGH; return CRITICAL;
    }
}