// import dotenv from "dotenv";
// dotenv.config();
// import app from "./app.js";

// app.listen(process.env.PORT, () =>
//   console.log("🚀 Backend running on port", process.env.PORT)
// );

// import dotenv from "dotenv";
// dotenv.config();
// import app from "./app.js";


// //only for demo purpose , in lamda their is no need to listen to any port as aws will handle it
// if (process.env.NODE_ENV !== "production") {
//   app.listen(process.env.PORT || 3000, () => {
//     console.log("🚀 Backend running locally");
//   });
// }


import dotenv from "dotenv";
dotenv.config();
import app from "./app.js";

// Listen in ALL environments except AWS Lambda
if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Backend running on port ${PORT}`);
  });
}