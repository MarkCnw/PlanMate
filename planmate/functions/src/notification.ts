// functions/src/notification.ts
import * as admin from "firebase-admin";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onDocumentWritten} from "firebase-functions/v2/firestore";

// ❌ ลบบรรทัดนี้ออก - เพราะ init แล้วใน index.ts
// admin.initializeApp();

// ❌ ลบบรรทัดนี้ออก - เพราะตั้งค่าแล้วใน index.ts
// setGlobalOptions({region: "asia-southeast1"});

// ===== HELPER FUNCTIONS =====

async function sendNotificationToUser(
  userId: string,
  notification: {
    title: string;
    body: string;
    data?: {[key: string]: string};
  }
) {
  const db = admin.firestore();
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    console.log(`User ${userId} not found`);
    return;
  }

  const userData = userDoc.data();
  const fcmToken = userData?.fcmToken;

  if (!fcmToken) {
    console.log(`No FCM token for user ${userId}`);
    return;
  }

  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      token: fcmToken,
    };

    await admin.messaging().send(message);
    console.log(`✅ Notification sent to user ${userId}`);
  } catch (error) {
    console.error(`❌ Failed to send notification to ${userId}:`, error);
  }
}

async function getUserTaskStats(userId: string) {
  const db = admin.firestore();
  const tasksSnapshot = await db
    .collection("tasks")
    .where("userId", "==", userId)
    .get();

  const tasks = tasksSnapshot.docs.map((doc) => doc.data());
  const total = tasks.length;
  const completed = tasks.filter((t) => t.isDone).length;
  const pending = tasks.filter((t) => !t.isDone).length;

  const now = new Date();
  const overdue = tasks.filter((t) => {
    if (t.isDone || !t.dueDate) return false;
    const dueDate = t.dueDate.toDate();
    return dueDate < now;
  }).length;

  return {total, completed, pending, overdue};
}

async function getWeeklyStats(userId: string) {
  const db = admin.firestore();
  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const completedSnapshot = await db
    .collection("tasks")
    .where("userId", "==", userId)
    .where("isDone", "==", true)
    .where("completedAt", ">=", weekAgo)
    .get();

  const totalSnapshot = await db
    .collection("tasks")
    .where("userId", "==", userId)
    .where("createdAt", ">=", weekAgo)
    .get();

  const completedCount = completedSnapshot.size;
  const createdCount = totalSnapshot.size;

  const productivityRate =
    createdCount > 0 ? Math.round((completedCount / createdCount) * 100) : 0;

  return {
    completedThisWeek: completedCount,
    createdThisWeek: createdCount,
    productivityRate,
  };
}

// ===== SCHEDULED FUNCTIONS =====

export const checkInactiveUsers = onSchedule(
  {schedule: "0 9 * * *", timeZone: "Asia/Bangkok"},
  async () => {
    console.log("🔄 Checking inactive users...");
    const db = admin.firestore();
    const usersSnapshot = await db.collection("users").get();

    const now = new Date();
    let notificationsSent = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userId = userDoc.id;
      const lastSignIn = userData.lastSignIn?.toDate();

      if (!lastSignIn) continue;

      const daysSinceLastSignIn = Math.floor(
        (now.getTime() - lastSignIn.getTime()) / (1000 * 60 * 60 * 24)
      );

      const stats = await getUserTaskStats(userId);

      if (daysSinceLastSignIn === 3 && stats.pending > 0) {
        await sendNotificationToUser(userId, {
          title: "คิดถึงคุณนะ! 🌟",
          body: `คุณมีงานค้าง ${stats.pending} งาน มาทำต่อกันเถอะ!`,
          data: {
            type: "inactive_reminder",
            days: "3",
            pendingTasks: stats.pending.toString(),
          },
        });
        notificationsSent++;
      } else if (daysSinceLastSignIn === 7 && stats.pending > 0) {
        await sendNotificationToUser(userId, {
          title: "เราคิดถึงคุณมาก! 💙",
          body: `ห่างหายกันไปนานแล้ว! คุณมีงานค้าง ${stats.pending} งาน`,
          data: {
            type: "inactive_reminder",
            days: "7",
            pendingTasks: stats.pending.toString(),
          },
        });
        notificationsSent++;
      } else if (daysSinceLastSignIn === 14 && stats.pending > 0) {
        await sendNotificationToUser(userId, {
          title: "มานานเกินไปแล้ว! 🎯",
          body: `2 สัปดาห์แล้ว! งานของคุณรออยู่ (${stats.pending} งาน)`,
          data: {
            type: "inactive_reminder",
            days: "14",
            pendingTasks: stats.pending.toString(),
          },
        });
        notificationsSent++;
      }
    }

    console.log(`✅ Sent ${notificationsSent} inactive user notifications`);
  }
);

export const sendWeeklySummary = onSchedule(
  {schedule: "0 20 * * 0", timeZone: "Asia/Bangkok"},
  async () => {
    console.log("🔄 Sending weekly summaries...");
    const db = admin.firestore();
    const usersSnapshot = await db.collection("users").get();

    let summariesSent = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const weeklyStats = await getWeeklyStats(userId);
      const currentStats = await getUserTaskStats(userId);

      if (weeklyStats.completedThisWeek === 0 && currentStats.total === 0) {
        continue;
      }

      let emoji = "📊";
      let message = "";

      if (weeklyStats.productivityRate >= 80) {
        emoji = "🔥";
        message = "สัปดาห์นี้คุณเจ๋งมาก!";
      } else if (weeklyStats.productivityRate >= 50) {
        emoji = "💪";
        message = "ทำได้ดีมาก! ต่อไปทำได้ดีกว่านี้";
      } else {
        emoji = "📈";
        message = "สัปดาห์หน้าลองทำให้ดีขึ้นนะ!";
      }

      await sendNotificationToUser(userId, {
        title: `${emoji} สรุปสัปดาห์นี้`,
        body:
          `${message}\n` +
          `✅ ทำเสร็จ: ${weeklyStats.completedThisWeek} งาน\n` +
          `📋 คงเหลือ: ${currentStats.pending} งาน\n` +
          `📊 Productivity: ${weeklyStats.productivityRate}%`,
        data: {
          type: "weekly_summary",
          completed: weeklyStats.completedThisWeek.toString(),
          pending: currentStats.pending.toString(),
          productivity: weeklyStats.productivityRate.toString(),
        },
      });

      summariesSent++;
    }

    console.log(`✅ Sent ${summariesSent} weekly summaries`);
  }
);

export const sendDailyReminder = onSchedule(
  {schedule: "0 18 * * *", timeZone: "Asia/Bangkok"},
  async () => {
    console.log("🔄 Sending daily reminders...");
    const db = admin.firestore();
    const usersSnapshot = await db.collection("users").get();

    let remindersSent = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const stats = await getUserTaskStats(userId);

      if (stats.pending === 0) continue;

      let emoji = "📝";
      let title = "เช็คงานวันนี้กันเถอะ!";

      if (stats.overdue > 0) {
        emoji = "⚠️";
        title = "มีงานเลยกำหนดแล้ว!";
      }

      await sendNotificationToUser(userId, {
        title: `${emoji} ${title}`,
        body:
          stats.overdue > 0 ?
            `งานเลยกำหนด: ${stats.overdue} งาน | ` +
              `งานค้าง: ${stats.pending} งาน` :
            `คุณมีงานค้าง ${stats.pending} งาน`,
        data: {
          type: "daily_reminder",
          pending: stats.pending.toString(),
          overdue: stats.overdue.toString(),
        },
      });

      remindersSent++;
    }

    console.log(`✅ Sent ${remindersSent} daily reminders`);
  }
);

// ===== REAL-TIME ACHIEVEMENT TRIGGERS =====

export const checkDailyAchievements = onDocumentWritten(
  "tasks/{taskId}",
  async (event) => {
    const after = event.data?.after?.data();
    const before = event.data?.before?.data();

    if (!after || !before) return;
    if (after.isDone === before.isDone) return;
    if (!after.isDone) return;

    const userId = after.userId;
    if (!userId) return;

    const db = admin.firestore();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const completedTodaySnapshot = await db
      .collection("tasks")
      .where("userId", "==", userId)
      .where("isDone", "==", true)
      .where("completedAt", ">=", today)
      .get();

    const completedCount = completedTodaySnapshot.size;

    const achievements = [
      {count: 1, title: "🎯 เริ่มต้นดีแล้ว!", body: "ทำงานเสร็จแรกวันนี้!"},
      {count: 5, title: "🔥 น่าทึ่งมาก!", body: "คุณปิดงานครบ 5 งานแล้ว!"},
      {count: 10, title: "⭐ ซูเปอร์สตาร์!", body: "10 งานใน 1 วัน! เจ๋งมาก!"},
      {count: 15, title: "🚀 ไม่มีใครหยุดคุณได้!", body: "15 งาน! คุณคือตำนาน!"},
    ];

    const achievement = achievements.find((a) => a.count === completedCount);

    if (achievement) {
      await sendNotificationToUser(userId, {
        title: achievement.title,
        body: achievement.body,
        data: {
          type: "achievement",
          achievementType: "daily_completion",
          count: completedCount.toString(),
        },
      });

      await db.collection("achievements").add({
        userId,
        type: "daily_completion",
        count: completedCount,
        achievedAt: admin.firestore.FieldValue.serverTimestamp(),
        title: achievement.title,
      });

      console.log(
        `✅ Achievement unlocked for user ${userId}: ${achievement.title}`
      );
    }
  }
);

export const checkProjectCompletion = onDocumentWritten(
  "tasks/{taskId}",
  async (event) => {
    const after = event.data?.after?.data();
    if (!after?.isDone || !after?.projectId) return;

    const db = admin.firestore();
    const projectId = after.projectId;
    const userId = after.userId;

    const projectTasksSnapshot = await db
      .collection("tasks")
      .where("projectId", "==", projectId)
      .where("userId", "==", userId)
      .get();

    const totalTasks = projectTasksSnapshot.size;
    const completedTasks = projectTasksSnapshot.docs.filter(
      (doc) => doc.data().isDone
    ).length;

    if (totalTasks > 0 && completedTasks === totalTasks) {
      const projectDoc = await db.collection("projects").doc(projectId).get();
      const projectTitle = projectDoc.data()?.title || "โปรเจค";

      await sendNotificationToUser(userId, {
        title: "🎉 เสร็จสมบูรณ์!",
        body: `คุณทำโปรเจค "${projectTitle}" เสร็จแล้ว! (${totalTasks} งาน)`,
        data: {
          type: "achievement",
          achievementType: "project_completion",
          projectId,
          taskCount: totalTasks.toString(),
        },
      });

      await db.collection("achievements").add({
        userId,
        type: "project_completion",
        projectId,
        projectTitle,
        taskCount: totalTasks,
        achievedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ Project completed: ${projectTitle}`);
    }
  }
);

// ===== MANUAL NOTIFICATION CALLABLE =====

export const sendTestNotification = onCall(async (req) => {
  if (!req.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }

  const userId = req.auth.uid;
  const {title, body} = req.data;

  await sendNotificationToUser(userId, {
    title: title || "🔔 ทดสอบการแจ้งเตือน",
    body: body || "นี่คือการแจ้งเตือนทดสอบ",
    data: {
      type: "test",
      timestamp: new Date().toISOString(),
    },
  });

  return {success: true, message: "Test notification sent"};
});
