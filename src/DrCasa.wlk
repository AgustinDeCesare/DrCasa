class EnfermedadInfecciosa {
	var property cantidadCelulasAmenazadas = 0

	method reproducirse(){
		cantidadCelulasAmenazadas *= 2
	}
	method aplicarEfecto(unaPersona){
		unaPersona.aumentarTemperatura(cantidadCelulasAmenazadas/1000)
	}
	method esAgresiva(cantidadCelulasPersona){
		return cantidadCelulasAmenazadas > cantidadCelulasPersona * 0.1
	}
	method atenuarEn(cantidadCelulas){
		cantidadCelulasAmenazadas -= cantidadCelulas
	}
}

class EnfermedadAutoinmune {
	var cantidadCelulasAmenazadas = 0
	var diasQueAfectaste = 0
	method aplicarEfecto(unaPersona){
		unaPersona.destruirCelulas(cantidadCelulasAmenazadas)
		diasQueAfectaste ++
	}
	method esAgresiva(cantidadCelulas){
		return diasQueAfectaste > 30
	}
	method atenuarEn(cantidadCelulas){
		cantidadCelulasAmenazadas -= cantidadCelulas
	}
}

class Persona {
	var enfermedades = #{}
	var temperatura = 36.5
	var cantidadCelulas = 0
	method contraerEnfermedad(unaEnfermedad){
		enfermedades.add(unaEnfermedad)
	}
	method tiene(unaEnfermedad){
		return enfermedades.contains(unaEnfermedad)
	}
	method vivirUnDia(){
		enfermedades.forEach({enfermedad => enfermedad.aplicarEfecto(self)})
	}
	method aumentarTemperatura(unosGrados){
		temperatura = 45.min(temperatura + unosGrados)
	}
	method destruirCelulas(unasCelulas){
		cantidadCelulas -= unasCelulas
	}
	method cantidadCelulasAmenazadasPorEnfermedadesAgresivas(){
		return self.enfermedadesAgresivas().sum({enfermedad => enfermedad.cantidadCelulasAmenazadas()})
	}
	method enfermedadesAgresivas(){
		return enfermedades.filter({enfermedad => enfermedad.esAgresiva(cantidadCelulas)})
	}
	method aplicarDosis(unaDosis){
		enfermedades.forEach({enfermedad => enfermedad.atenuarEn(unaDosis*15)})
	}
}

class Medico inherits Persona{
	var property dosis
	
	method atenderA(unaPersona){
		unaPersona.aplicarDosis(dosis)
	}
}

class JefeDeDepartamento inherits Medico {
	var subordinados = #{}
	override method atenderA(unaPersona){
		subordinados.anyOne().atenderA(unaPersona)
	}
}