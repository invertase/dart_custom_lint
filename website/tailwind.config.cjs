/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
	darkMode: 'class',
	theme: {
		extend: {
			fontFamily: {
				itc: "Arial, sans-serif;",
			},
			boxShadow: {
				footer: '0px -2px 227px rgba(0, 0, 0, 0.14)'
			},
			colors: {
				linter: {
					DEFAULT: 'var(--primary)',
					background: 'var(--background)',
				},
			},
		},
	},
	plugins: [],
}