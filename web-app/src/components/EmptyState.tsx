"use client";

import Image from "next/image";

export default function EmptyState({
  title,
  subtitle,
}: {
  title: string;
  subtitle?: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
      <Image src="/empty_widget.png" alt="فارغ" width={200} height={200} className="opacity-60 mb-6" />
      <h3 className="text-lg font-bold text-gray-700 mb-2">{title}</h3>
      {subtitle && <p className="text-sm text-gray-500 max-w-sm">{subtitle}</p>}
    </div>
  );
}
