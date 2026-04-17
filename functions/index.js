const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Teacher pushes schedule updates (temporary schedule changes) to one or more children.
 * Input document path: schools/{schoolId}/teacherUpdates/{updateId}
 * Expected payload: {
 *   childIds: string[],
 *   change: { title, startsAt, endsAt, note },
 *   createdBy: teacherUid
 * }
 */
exports.pushScheduleUpdateToChildren = onDocumentCreated(
  'schools/{schoolId}/teacherUpdates/{updateId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) {
      logger.warn('No payload found for schedule update event.');
      return;
    }

    const childIds = Array.isArray(data.childIds) ? data.childIds : [];
    if (childIds.length === 0) {
      logger.warn('No childIds provided in schedule update.', { updateId: event.params.updateId });
      return;
    }

    const db = admin.firestore();
    const now = admin.firestore.FieldValue.serverTimestamp();

    const writes = childIds.map((childId) => {
      const ref = db
        .collection('children')
        .doc(childId)
        .collection('inbox')
        .doc('latestScheduleUpdate');

      return ref.set(
        {
          type: 'SCHEDULE_CHANGE',
          schoolId: event.params.schoolId,
          updateId: event.params.updateId,
          change: data.change ?? {},
          createdBy: data.createdBy ?? null,
          createdAt: now,
          acknowledged: false,
        },
        { merge: true }
      );
    });

    await Promise.all(writes);
    logger.info('Schedule update pushed to children.', {
      updateId: event.params.updateId,
      childCount: childIds.length,
    });
  }
);
