import type { ReactNode } from "react";

export function Card({
  children,
  className = ""
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={`rounded-2xl border border-slate-100 bg-white p-4 shadow-soft ${className}`}>
      {children}
    </section>
  );
}

export function PrimaryButton({
  children,
  onClick,
  type = "button",
  disabled = false,
  className = ""
}: {
  children: ReactNode;
  onClick?: () => void;
  type?: "button" | "submit";
  disabled?: boolean;
  className?: string;
}) {
  return (
    <button
      type={type}
      disabled={disabled}
      onClick={onClick}
      className={`w-full rounded-2xl bg-calm-500 px-5 py-4 text-base font-bold text-white shadow-lg shadow-calm-500/20 transition active:scale-[0.99] disabled:cursor-not-allowed disabled:bg-slate-300 ${className}`}
    >
      {children}
    </button>
  );
}

export function MetricCard({
  label,
  value,
  sub
}: {
  label: string;
  value: string | number;
  sub?: string;
}) {
  return (
    <div className="rounded-2xl border border-slate-100 bg-white p-4 shadow-sm">
      <p className="text-xs font-semibold text-slate-500">{label}</p>
      <p className="mt-2 text-2xl font-bold text-slate-900">{value}</p>
      {sub ? <p className="mt-1 text-xs text-slate-500">{sub}</p> : null}
    </div>
  );
}

export function RangeField({
  label,
  value,
  onChange
}: {
  label: string;
  value: number;
  onChange: (value: number) => void;
}) {
  return (
    <label className="block rounded-2xl border border-slate-100 bg-white p-4">
      <div className="flex items-center justify-between gap-3">
        <span className="text-sm font-bold text-slate-700">{label}</span>
        <span className="min-w-12 rounded-full bg-skycare-50 px-3 py-1 text-center text-sm font-bold text-skycare-700">
          {value}
        </span>
      </div>
      <input
        type="range"
        min="0"
        max="10"
        value={value}
        onChange={(event) => onChange(Number(event.target.value))}
        className="mt-4 w-full accent-calm-500"
      />
      <div className="mt-1 flex justify-between text-[11px] text-slate-400">
        <span>なし</span>
        <span>強い</span>
      </div>
    </label>
  );
}

export function Notice() {
  return (
    <p className="rounded-2xl bg-slate-50 p-4 text-xs leading-6 text-slate-500">
      このアプリはセルフケア支援を目的としたもので、診断・治療を行うものではありません。痛み、顎関節症状、歯の違和感が強い場合は歯科医師に相談してください。
    </p>
  );
}
