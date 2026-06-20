"use client";

import React from "react";

interface SelectFieldProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
  options: { value: string; label: string }[];
  placeholder?: string;
}

export default function SelectField({ label, error, options, placeholder, className = "", ...props }: SelectFieldProps) {
  return (
    <div className="w-full">
      {label && <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>}
      <select
        className={`w-full rounded-xl border border-gray-300 bg-gray-50 py-3 px-4 text-gray-900 focus:border-[#21406c] focus:ring-2 focus:ring-[#21406c]/20 focus:outline-none transition-all ${
          error ? "border-red-500" : ""
        } ${className}`}
        {...props}
      >
        {placeholder && (
          <option value="" disabled>
            {placeholder}
          </option>
        )}
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
    </div>
  );
}
