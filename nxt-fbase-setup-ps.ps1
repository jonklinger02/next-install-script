# Install dependencies
npm init -y
npm install next@latest react react-dom firebase
npm install -D firebase-tools
npm install -D tailwindcss
npx tailwindcss init
npm install -D daisyui@latest
npm install typescript
npm install @types/react
npm install @next/third-parties

# Create Next.js app structure
New-Item -ItemType Directory -Force -Path app, components, data, styles, firebase
New-Item -ItemType File -Force -Path app/page.tsx


# Create Firebase config file
@"
i// import firebase
import firebase from 'firebase/app';

// import modules
import 'firebase/auth';
import 'firebase/firestore';
import 'firebase/analytics';

// import analytics SDK
import { getAnalytics } from 'firebase/analytics';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTHDOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECTID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGEBUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGINGSENDERID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APPID,
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENTID,
};

export default function initFirebase() {
  if (!firebase.getApps.length) {
    const app = firebase.initializeApp(firebaseConfig);
    // check that the 'window' is in scope for analytics
    if (typeof window !== 'undefined') {
      if ('measurementId' in firebaseConfig) {
        getAnalytics(app);
      }
    }
  }
}

const db = getFirestore(app);

export { db };
"@ | Out-File -FilePath firebaseConfig.js -Encoding utf8

# Create next.config.js
@"
const nextConfig = {
    output: 'export',
    images: {
      unoptimized: true,
    },
  }
"@ | Out-File -FilePath next.config.mjs -Encoding utf8

# Update package.json scripts
npm pkg set scripts.dev="next dev"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start"
npm pkg set scripts.export="next build && next export"
npm pkg set scripts.deploy="npm run export && firebase deploy"

# Create a basic index page
@"
//import { useEffect, useState } from 'react';
import { db } from '../firebaseConfig';
import { collection, getDocs } from 'firebase/firestore';

export default function Home() {
  /*const [data, setData] = useState([]);

  useEffect(() => {
    async function fetchData() {
      const querySnapshot = await getDocs(collection(db, 'your-collection'));
      setData(querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    }
    fetchData();
  }, []);*/

  return (
    <div>
      <h1>Welcome to your Next.js Firebase app!</h1>
      {/*{data.map(item => (
        <div key={item.id}>{JSON.stringify(item)}</div>
))}*/}S
    </div>
  );
}
"@ | Out-File -FilePath app/page.tsx -Encoding utf8

# Create firebase.json for hosting configuration
@"
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": [
        "node_modules",
        ".git",
        "firebase-debug.log",
        "firebase-debug.*.log",
        "*.local"
      ],
      "predeploy": [
        'npm --prefix \"$RESOURCE_DIR\" run lint',
        'npm --prefix \"$RESOURCE_DIR\" run build'
      ]
    }
  ],
  "hosting": {
    "public": "out",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "headers": [
      {
        "source": "**/*.webp",
        "headers": [
          {
            "key": "Content-Type",
            "value": "image/webp"
          }
        ]
      }
    ]
  }
}
"@ | Out-File -FilePath firebase.json -Encoding utf8

# create tailwind.config.js for css configuration
@"
/** @type {import('tailwindcss').Config} */

module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',

    // Or if using `src` directory:
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    screens: {
      sm: '480px',
      md: '820px',
      lg: '976px',
      xl: '1088px',
    },
    colors: {
      transparent: 'transparent',
      brown: '#362312',
      hickory: '#351E10',
      primary: '#000000',
      secondary: '#ffffff',
    },

    extend: {
      borderRadius: {
        '4xl': '2.5rem',
      },
    },
  },
  plugins: [require('daisyui')],

  daisyui: {
    themes: [
      {
        light: {
          primary: '#1c232b',
          secondary: '#ffffff',
          accent: '#292f2d',
          neutral: '#07180f',
          'base-100': '#1c232b',
        },
      },
    ], // false: only light + dark | true: all themes | array: specific themes like this ["light", "dark", "cupcake"]
    darkTheme: 'dark', // name of one of the included themes for dark mode
    base: false, // applies background color and foreground color for root element by default
    styled: true, // include daisyUI colors and design decisions for all components
    utils: true, // adds responsive and modifier utility classes
    prefix: '', // prefix for daisyUI classnames (components, modifiers and responsive class names. Not colors)
    logs: true, // Shows info about daisyUI version and used config in the console when building your CSS
    themeRoot: ':root', // The element that receives theme color CSS variables
  },
};
"@ | Out-File -FilePath tailwind.config.js -Encoding utf8

# Create .eslintrc.json for linting configuration
@"
{
  "extends": ["next", "next/core-web-vitals", "prettier", "eslint:recommended"],
  "globals": {
    "React": "readonly"
  },
  "rules": {
    "no-unused-vars": "warn"
  }
}
"@ | Out-File -FilePath .eslintrc.json -Encoding utf8

# Create tsconfig.json for typscript configuration
@"
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "allowImportingTsExtensions": true,
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
"@ | Out-File -FilePath tsconfig.json -Encoding utf8

# Create postcss.config.json for hosting configuration
@"
module.exports = {
  plugins: {
    'postcss-import': {},
    'tailwindcss/nesting': 'postcss-nesting',
    tailwindcss: { config: './tailwind.config.js' },
    autoprefixer: {},
  },
};
"@ | Out-File -FilePath postcss.config.json -Encoding utf8

# Create global.d.ts for global declarations
@"
declare module '*.webp' {
    const content: StaticImageData;
    export default content;
  }
"@ | Out-File -FilePath firebase.json -Encoding utf8

# Create .prettierrc for prettier standards configuration
@"
{
  "tabWidth": 2,
  "semi": true,
  "singleQuote": true
}
"@ | Out-File -FilePath .prettierrc -Encoding utf8

# Create .npmrc for npm restrictions configuration
@"
engine-strict=true
"@ | Out-File -FilePath .npmrc -Encoding utf8

# Create styles/globals.css for hosting configuration
@"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@ | Out-File -FilePath ./styles/globals.css -Encoding utf8

# Create .env.local for local environment
@"
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTHDOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECTID=
NEXT_PUBLIC_FIREBASE_STORAGEBUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGINGSENDERID=
NEXT_PUBLIC_FIREBASE_APPID=
NEXT_PUBLIC_FIREBASE_MEASUREMENTID=
"@ | Out-File -FilePath .env.local -Encoding utf8

# Run the CLI tool to scan template files for classes and build your CSS.
npx tailwindcss -i ./src/input.css -o ./src/output.css --watch

Write-Output "Setup complete. Don't forget to add your Firebase configuration to firebaseConfig.js"