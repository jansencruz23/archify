import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

exports.checkVotingDeadlines = functions.pubsub
  .schedule("every 1 minutes").onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    try {
      const snapshot = await admin.firestore()
        .collection("Days")
        .where("votingDeadline", "<=", now)
        .get();

      if (snapshot.empty) {
        console.log("No deadlines met");
        return null;
      }

      const notifications: admin.messaging.Message[] = [];

      snapshot.forEach((doc) => {
        const data = doc.data();
        const participants = data.participants || [];

        participants.forEach((participant: { fcmToken: string }) => {
          notifications.push({
            notification: {
              title: "Voting Deadline Reached!",
              body: "The voting for ${data.name} has ended.",
            },
            token: participant.fcmToken,
          });
        });

        doc.ref.update({notified: true});
      });

      if (notifications.length > 0) {
        await admin.messaging().sendEach(notifications);
        console.log("Notifications sent.");
        }}

    catch (error) {
      console.error("Error checking deadlines:", error);
    }

    return null;
  });
