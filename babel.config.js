module.exports = (api) => {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `${'Please specify a valid `NODE_ENV` or '
        + '`BABEL_ENV` environment variables. Valid values are "development", '
        + '"test", and "production". Instead, received: '}${
        JSON.stringify(currentEnv)
      }.`,
    );
  }

  return {
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTestEnv && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      [
        '@babel/plugin-proposal-class-properties',
        {
          loose: true,
        },
      ],
      [
        '@babel/plugin-proposal-object-rest-spread',
        {
          useBuiltIns: true,
        },
      ],
      [
        '@babel/plugin-transform-runtime',
        {
          corejs: false,
          helpers: false,
          regenerator: true,
        },
      ],
      [
        '@babel/plugin-transform-regenerator',
        {
          async: false,
        },
      ],
    ].filter(Boolean),
    presets: [
      isTestEnv && [
        '@babel/preset-env',
        {
          targets: {
            node: 'current',
          },
        },
      ],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          corejs: 3,
          exclude: ['transform-typeof-symbol'],
          forceAllTransforms: true,
          modules: false,
          useBuiltIns: 'entry',
        },
      ],
    ].filter(Boolean),
  };
};
