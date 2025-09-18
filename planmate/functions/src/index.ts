import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, HttpsError} from "firebase-functions/v2/https";

// init firebase
admin.initializeApp();

// ตั้งค่า region ใกล้ไทย
setGlobalOptions({region: "asia-southeast1"});

// ✅ 1) Cleanup อัตโนมัติทุกวัน 02:00
export const cleanupOldActivities = onSchedule(
  {schedule: "0 2 * * *", timeZone: "Asia/Bangkok"},
  async () => {
    const db = admin.firestore();
    const activitiesRef = db.collection("activities");
    const retentionDays = 7;
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

    let totalDeleted = 0;
    const batchSize = 500;
    let hasMore = true;

    while (hasMore) {
      const snapshot = await activitiesRef
        .where("timestamp", "<", cutoffDate.toISOString())
        .limit(batchSize)
        .get();

      if (snapshot.empty) {
        hasMore = false;
        break;
      }

      const batch = db.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();

      totalDeleted += snapshot.size;
      if (snapshot.size < batchSize) {
        hasMore = false;
      }
    }

    console.log(`✅ Deleted ${totalDeleted} old activities`);
    // ❌ ไม่ต้อง return object
    // ✅ return void (Promise<void>)
  }
);


// ✅ 2) Cleanup manual (callable)
export const testCleanup = onCall(async (req) => {
  if (!req.auth?.token?.admin) {
    throw new HttpsError("permission-denied", "Only admin can trigger cleanup");
  }

  const db = admin.firestore();
  const activitiesRef = db.collection("activities");

  const retentionDays = req.data.days || 7;
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

  const maxDelete = req.data.maxDelete || 100;
  const snapshot = await activitiesRef
    .where("timestamp", "<", cutoffDate.toISOString())
    .limit(maxDelete)
    .get();

  if (snapshot.empty) {
    return {success: true, message: "No old activities found"};
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  return {success: true, deleted: snapshot.size};
});

// ✅ 3) Stats (callable)
export const getCleanupStats = onCall(async () => {
  const db = admin.firestore();
  const activitiesRef = db.collection("activities");

  const retentionDays = 7;
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

  const oldSnap = await activitiesRef
    .where("timestamp", "<", cutoffDate.toISOString())
    .get();

  const recentSnap = await activitiesRef
    .where("timestamp", ">=", cutoffDate.toISOString())
    .get();

  const totalSnap = await activitiesRef.get();

  return {
    total: totalSnap.size,
    old: oldSnap.size,
    recent: recentSnap.size,
    retentionDays,
    cutoffDate: cutoffDate.toISOString(),
  };
});
