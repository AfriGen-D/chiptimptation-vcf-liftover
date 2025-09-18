import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'ChipTimputation VCF Liftover',
  titleTemplate: ':title | AfriGen-D',
  description: 'A robust Nextflow pipeline for converting VCF files between genome builds using CrossMap - developed by AfriGen-D',
  base: '/chiptimputation-vcf-liftover/',
  ignoreDeadLinks: true,
  lang: 'en-US',

  head: [
    ['link', { rel: 'icon', href: '/chiptimputation-vcf-liftover/logo.png' }],
    ['meta', { name: 'theme-color', content: '#3c82f6' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:locale', content: 'en' }],
    ['meta', { property: 'og:title', content: 'ChipTimputation VCF Liftover | AfriGen-D' }],
    ['meta', { property: 'og:site_name', content: 'ChipTimputation VCF Liftover' }],
    ['meta', { property: 'og:image', content: 'https://afrigen-d.github.io/chiptimputation-vcf-liftover/logo.png' }],
    ['meta', { property: 'og:url', content: 'https://afrigen-d.github.io/chiptimputation-vcf-liftover/' }],
    ['meta', { property: 'og:description', content: 'A robust Nextflow pipeline for converting VCF files between genome builds using CrossMap - developed by AfriGen-D' }]
  ],

  themeConfig: {
    logo: {
      src: '/logo.png',
      width: 40,
      height: 40,
      alt: 'AfriGen-D ChipTimputation VCF Liftover'
    },
    siteTitle: 'ChipTimputation VCF Liftover',

    // Add announcement banner
    announcement: {
      title: '🎉 New Quick Start Tutorial Available!',
      details: 'Get started with VCF liftover in just 10 minutes',
      link: '/tutorials/quick-start'
    },

    nav: [
      { text: 'Home', link: '/', activeMatch: '^/$' },
      {
        text: 'Get Started',
        activeMatch: '^/(guide|tutorials)/',
        items: [
          {
            text: '🚀 Quick Start (10 min)',
            link: '/tutorials/quick-start',
            target: '_self'
          },
          {
            text: '⚙️ Installation Guide',
            link: '/guide/installation',
            target: '_self'
          },
          {
            text: '🔧 Configuration',
            link: '/guide/configuration',
            target: '_self'
          },
          {
            text: '📋 Requirements',
            link: '/guide/getting-started',
            target: '_self'
          }
        ]
      },
      {
        text: 'Documentation',
        link: '/docs/',
        activeMatch: '^/docs/'
      },
      {
        text: 'Reference',
        link: '/reference/',
        activeMatch: '^/reference/'
      },
      {
        text: 'Tutorials',
        link: '/tutorials/',
        activeMatch: '^/tutorials/'
      },
      {
        text: 'Examples',
        link: '/examples/',
        activeMatch: '^/examples/'
      }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          collapsed: false,
          items: [
            { text: 'Introduction', link: '/guide/getting-started' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Quick Start', link: '/guide/quick-start' },
            { text: 'Configuration', link: '/guide/configuration' }
          ]
        },
        {
          text: 'Advanced Usage',
          collapsed: false,
          items: [
            { text: 'Input Files', link: '/guide/input-files' },
            { text: 'Configuration', link: '/guide/configuration' }
          ]
        }
      ],
      '/reference/': [
        {
          text: 'Command Line Reference',
          collapsed: false,
          items: [
            { text: 'Reference Overview', link: '/reference/' },
            { text: 'Parameters', link: '/reference/parameters' },
            { text: 'Profiles', link: '/reference/profiles' },
            { text: 'Test Data', link: '/reference/test-data' },
            { text: 'Configuration', link: '/reference/configuration' }
          ]
        }
      ],
      '/workflow/': [
        {
          text: 'Workflow Details',
          collapsed: false,
          items: [
            { text: 'Overview', link: '/workflow/' },
            { text: 'Process Flow', link: '/workflow/process-flow' },
            { text: 'Subworkflows', link: '/workflow/subworkflows' },
            { text: 'Resource Usage', link: '/workflow/resources' }
          ]
        }
      ],
      '/tutorials/': [
        {
          text: 'Step-by-Step Tutorials',
          collapsed: false,
          items: [
            { text: 'Tutorial Overview', link: '/tutorials/' },
            { text: 'Quick Start (10 min)', link: '/tutorials/quick-start' },
            { text: 'Multi-File Tutorial', link: '/tutorials/multi-file-tutorial' },
            { text: 'Method Selection', link: '/tutorials/method-selection' }
          ]
        }
      ],
      '/docs/': [
        {
          text: 'Core Concepts',
          collapsed: false,
          items: [
            { text: 'Documentation Overview', link: '/docs/' },
            { text: 'Liftover Methods', link: '/docs/liftover-methods' },
            { text: 'Single File Analysis', link: '/docs/single-file' },
            { text: 'Understanding Results', link: '/docs/understanding-results' }
          ]
        },
        {
          text: 'Processing Workflows',
          collapsed: false,
          items: [
            { text: 'Multi-File Processing', link: '/docs/multi-file' },
            { text: 'Quality Control', link: '/docs/quality-control' }
          ]
        },
        {
          text: 'Reference Materials',
          collapsed: false,
          items: [
            { text: 'Troubleshooting', link: '/docs/troubleshooting' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/AfriGen-D/chiptimputation-vcf-liftover' },
      {
        icon: {
          svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Docker</title><path d="M13.983 11.078h2.119a.186.186 0 00.186-.185V9.006a.186.186 0 00-.186-.186h-2.119a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.185m-2.954-5.43h2.118a.186.186 0 00.186-.186V3.574a.186.186 0 00-.186-.185h-2.118a.185.185 0 00-.185.185v1.888c0 .102.082.185.185.186m0 2.716h2.118a.187.187 0 00.186-.186V6.29a.186.186 0 00-.186-.185h-2.118a.185.185 0 00-.185.185v1.887c0 .102.082.185.185.186m-2.93 0h2.12a.186.186 0 00.184-.186V6.29a.185.185 0 00-.185-.185H8.1a.185.185 0 00-.185.185v1.887c0 .102.083.185.185.186m-2.964 0h2.119a.186.186 0 00.185-.186V6.29a.185.185 0 00-.185-.185H5.136a.186.186 0 00-.186.185v1.887c0 .102.084.185.186.186m5.893 2.715h2.118a.186.186 0 00.186-.185V9.006a.186.186 0 00-.186-.186h-2.118a.185.185 0 00-.185.185v1.888c0 .102.082.185.185.185m-2.93 0h2.12a.185.185 0 00.184-.185V9.006a.185.185 0 00-.184-.186h-2.12a.185.185 0 00-.184.185v1.888c0 .102.083.185.185.185m-2.964 0h2.119a.185.185 0 00.185-.185V9.006a.185.185 0 00-.184-.186h-2.12a.186.186 0 00-.186.186v1.887c0 .102.084.185.186.185m0 2.715h2.119a.185.185 0 00.185-.185v-1.888a.185.185 0 00-.184-.185h-2.12a.185.185 0 00-.185.185v1.888c0 .102.084.185.186.185m16.646-7.22c-.46-.02-.94.02-1.26.14-.55-.02-1.26.04-2.02.27a.142.142 0 00-.1.17c.06.14.14.24.22.34 1.06-.83 2.572-.84 4.24-.34l.28.14c.26-.48.32-1.01.24-1.55a.186.186 0 00-.37-.11c-.22.45-.44.84-.73 1.07-.14-.01-.28-.02-.42-.02-.51 0-.98.03-1.42.08z"/></svg>'
        },
        link: 'https://hub.docker.com/u/afrigend'
      }
    ],

    footer: {
      message: '🧬 Developed by <a href="https://github.com/AfriGen-D" target="_blank">AfriGen-D</a> • Released under the MIT License',
      copyright: 'Copyright © 2025 AfriGen-D Project • African Genomics Research Initiative'
    },

    search: {
      provider: 'local',
      options: {
        placeholder: 'Search documentation...',
        translations: {
          button: {
            buttonText: 'Search',
            buttonAriaLabel: 'Search documentation'
          },
          modal: {
            displayDetails: 'Display detailed list',
            resetButtonTitle: 'Reset search',
            backButtonTitle: 'Close search',
            noResultsText: 'No results for',
            footer: {
              selectText: 'to select',
              selectKeyAriaLabel: 'enter',
              navigateText: 'to navigate',
              navigateUpKeyAriaLabel: 'up arrow',
              navigateDownKeyAriaLabel: 'down arrow',
              closeText: 'to close',
              closeKeyAriaLabel: 'escape'
            }
          }
        }
      }
    },

    editLink: {
      pattern: 'https://github.com/AfriGen-D/chiptimputation-vcf-liftover/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },

    lastUpdated: {
      text: 'Last updated',
      formatOptions: {
        dateStyle: 'short',
        timeStyle: 'medium'
      }
    }
  },

  markdown: {
    lineNumbers: true,
    math: true
  }
})