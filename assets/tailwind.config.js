// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      backgroundImage: {
        "alexandria-scrolls":
          "linear-gradient(180deg,rgba(0,0,0,.8) 0,rgba(0,0,0,.6) 30%,rgba(0,0,0,.3)), url('/images/alexandria_scrolls_commentaries.jpg')",
        pausanias:
          "url('/images/Pausanias_Description_of_Greece.jpg')",
      },
    },
    fontFamily: {
      // Helvetica messes up kerning when diacritics are involved
      'sans': ["Inter", "Arial", ...defaultTheme.fontFamily.sans]
    }
  },
  plugins: [require("@tailwindcss/forms")],
};
