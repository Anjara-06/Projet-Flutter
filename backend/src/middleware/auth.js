const jwt = require('jsonwebtoken');

/// Vérifie qu'un token JWT valide est présent dans l'en-tête Authorization.
/// Bloque la requête avec 401 si absent ou invalide.
function authentifier(req, res, next) {
  const enTete = req.headers.authorization;

  if (!enTete || !enTete.startsWith('Bearer ')) {
    return res.status(401).json({ erreur: 'Token manquant' });
  }

  const token = enTete.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.utilisateurId = payload.utilisateurId;
    next();
  } catch (err) {
    return res.status(401).json({ erreur: 'Token invalide ou expiré' });
  }
}

module.exports = { authentifier };
