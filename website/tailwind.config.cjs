/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
	darkMode: 'class',
	theme: {
		extend: {
			fontFamily: {
				itc: '"ITC Avant Garde Gothic Book", Arial, sans-serif;',
			},
			boxShadow: {
				footer: '0px -2px 227px rgba(0, 0, 0, 0.14)'
			},
			colors: {
				linter: {
					DEFAULT: 'var(--primary)',
					background: 'var(--background)',
					card: '#2C1E3C',
					toggle: '#261F3C'
				},
			},
		},
	},
	plugins: [],
}