const admin = require("firebase-admin");
const fs = require("fs");

// Initialize Firebase Admin
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function importHolidays() {
  try {
    // Read the holidays JSON file
    const raw = fs.readFileSync("./holidays2026.json", "utf8");
    const data = JSON.parse(raw);

    const year = data.year;
    const holidays = data.holidays;

    // Convert date strings to Firestore Timestamps
    const mappedHolidays = holidays.map((h) => ({
      id: h.id,
      date: admin.firestore.Timestamp.fromDate(new Date(h.date)),
      name: h.name,
      namebn: h.namebn,
      description: h.description,
      descriptionbn: h.descriptionbn,
      type: h.type,
      isGovtHoliday: h.isGovtHoliday,
    }));

    // Write to Firestore: /holidays/{year}
    await db.collection("holidays").doc(year).set({
      holidays: mappedHolidays,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Successfully imported ${mappedHolidays.length} holidays for ${year}`);
  } catch (error) {
    console.error("❌ Import failed:", error);
  } finally {
    process.exit();
  }
}

importHolidays();