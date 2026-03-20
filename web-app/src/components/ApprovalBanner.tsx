"use client";

import Link from "next/link";
import Image from "next/image";
import { useAuth } from "@/lib/auth-context";
import { useI18n } from "@/lib/i18n";

/**
 * Banner shown when the user's account is not approved.
 * - If ID images are missing, prompts the user to upload them.
 * - Otherwise shows a "pending approval" message.
 */
export default function ApprovalBanner() {
  const { userData } = useAuth();
  const { t } = useI18n();

  if (!userData || userData.isApproved) return null;

  const missingId = !userData.frontId && !userData.backId;

  if (missingId) {
    return (
      <div className="bg-orange-50 border border-orange-200 rounded-2xl p-4 flex flex-col sm:flex-row items-center gap-4">
        <Image src="/wating_approval.png" alt="" width={64} height={64} className="shrink-0" />
        <div className="flex-1 text-center sm:text-start">
          <h3 className="font-bold text-orange-800 mb-1">{t("uploadIdRequired")}</h3>
          <p className="text-sm text-orange-700">{t("uploadIdMessage")}</p>
        </div>
        <Link
          href="/main/upload-id"
          className="shrink-0 bg-[#21406c] text-white px-5 py-2.5 rounded-xl text-sm font-semibold hover:bg-[#415a81] transition-colors"
        >
          {t("uploadIdAction")}
        </Link>
      </div>
    );
  }

  return (
    <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-4 flex flex-col sm:flex-row items-center gap-4">
      <Image src="/wating_approval.png" alt="" width={64} height={64} className="shrink-0" />
      <div className="flex-1 text-center sm:text-start">
        <h3 className="font-bold text-yellow-800 mb-1">{t("pendingApproval")}</h3>
        <p className="text-sm text-yellow-700">{t("pendingApprovalMessage")}</p>
      </div>
    </div>
  );
}
